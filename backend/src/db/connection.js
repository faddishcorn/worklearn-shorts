import { DatabaseSync } from 'node:sqlite'
import { pathToFileURL } from 'node:url'
import { resolveDatabasePath } from '../config/paths.js'

export function openExistingDatabase(databasePath) {
  const databaseUrl = pathToFileURL(resolveDatabasePath(databasePath))
  databaseUrl.searchParams.set('mode', 'rw')

  // Keep the handle available for cleanup if opening the database fails.
  const database = new DatabaseSync(databaseUrl.href, { open: false })

  try {
    database.open()
    // Foreign key enforcement must be enabled before any transaction starts.
    database.exec('PRAGMA foreign_keys = ON')

    if (database.prepare('PRAGMA foreign_keys').get()?.foreign_keys !== 1) {
      throw new Error('Unable to enable foreign key constraints.')
    }

    return database
  } catch (error) {
    try {
      closeDatabase(database)
    } catch (closeError) {
      throw new AggregateError([error, closeError], 'Database opening and cleanup failed.')
    }

    throw error
  }
}

export function closeDatabase(database) {
  if (database.isOpen) {
    database.close()
  }
}
