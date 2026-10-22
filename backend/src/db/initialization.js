import { lstatSync } from 'node:fs'
import { resolveDatabasePath } from '../config/paths.js'

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
