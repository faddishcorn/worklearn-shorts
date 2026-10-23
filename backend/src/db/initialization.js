import { closeSync, lstatSync, mkdirSync, openSync, readFileSync } from 'node:fs'
import { dirname } from 'node:path'
import { resolveDatabasePath } from '../config/paths.js'
import { closeDatabase, openExistingDatabase } from './connection.js'
import { withTransaction } from './transaction.js'
import { verifyDatabaseSchema } from './schema-validation.js'

export function assertDatabaseDoesNotExist(databasePath) {
  const resolvedPath = resolveDatabasePath(databasePath)

  try {
    lstatSync(resolvedPath)
  } catch (error) {
    if (error.code === 'ENOENT') {
      // Creation must still use exclusive access after this early guard.
      return resolvedPath
    }

    throw error
  }

  const error = new Error('Database initialization refused because the target already exists.')
  error.code = 'EEXIST'
  throw error
}

export function prepareDatabaseParentDirectory(databasePath) {
  const resolvedPath = assertDatabaseDoesNotExist(databasePath)
  mkdirSync(dirname(resolvedPath), { recursive: true })
  return resolvedPath
}

export function createDatabaseFile(databasePath) {
  const resolvedPath = prepareDatabaseParentDirectory(databasePath)
  // The initialization owner must keep and finally close this handle.
  const fileDescriptor = openSync(resolvedPath, 'wx', 0o600)
  return { databasePath: resolvedPath, fileDescriptor }
}

export function applyDatabaseSchema(database) {
  const schema = readFileSync(new URL('../../db/schema.sql', import.meta.url), 'utf8')

  withTransaction(database, connection => {
    // Check and apply under the same write lock to protect existing schemas.
    if (connection.prepare('SELECT 1 FROM sqlite_schema LIMIT 1').get()) {
      const error = new Error('Database initialization requires an empty schema.')
      error.code = 'EEXIST'
      throw error
    }

    connection.exec(schema)
    verifyDatabaseSchema(connection)
  })
}

export function initializeDatabase(databasePath) {
  const createdFile = createDatabaseFile(databasePath)
  const errors = []
  let database

  try {
    database = openExistingDatabase(createdFile.databasePath)
    applyDatabaseSchema(database)
  } catch (error) {
    errors.push(error)
  } finally {
    // Release the SQLite connection before the exclusively created file handle.
    try {
      if (database) {
        closeDatabase(database)
      }
    } catch (error) {
      errors.push(error)
    }

    // A connection cleanup failure must not prevent file handle cleanup.
    try {
      closeSync(createdFile.fileDescriptor)
    } catch (error) {
      errors.push(error)
    }
  }

  if (errors.length === 1) {
    throw errors[0]
  }

  if (errors.length > 1) {
    throw new AggregateError(errors, 'Database initialization and resource cleanup failed.')
  }

  return { databasePath: createdFile.databasePath }
}
