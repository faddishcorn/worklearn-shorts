import fs from 'node:fs'
import path from 'node:path'
import { config } from '../src/config.js'

if (fs.existsSync(config.dbPath)) {
  console.error(`이미 DB가 있습니다: ${config.dbPath}`)
  console.error('처음부터 다시 만들려면 DB 파일(.db, .db-wal, .db-shm)을 지우고 다시 실행하세요.')
  process.exit(1)
}

const { db } = await import('../src/db.js')
db.exec(fs.readFileSync(path.join(config.backendDir, 'schema.sql'), 'utf8'))
console.log('DB 초기화 완료:', config.dbPath)