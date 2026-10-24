import fs from 'node:fs'
import path from 'node:path'
import express from 'express'
import { config } from './config.js'
import { db } from './db.js'

fs.mkdirSync(path.join(config.uploadDir, 'videos'), { recursive: true })
fs.mkdirSync(path.join(config.uploadDir, 'thumbnails'), { recursive: true })

export const app = express()
app.use(express.json())
app.use('/uploads', express.static(config.uploadDir, { index: false }))

app.get('/api/tags', (req, res) => {
  const data = db.prepare('SELECT id, name FROM tags ORDER BY name').all()
  res.json({ data })
})

app.use((req, res) => {
  res.status(404).json({ code: 'NOT_FOUND', message: '요청한 대상을 찾을 수 없습니다.', fields: {} })
})

app.use((err, req, res, next) => {
  if (err.type === 'entity.parse.failed') {
    return res.status(400).json({ code: 'INVALID_JSON', message: 'JSON 형식이 올바르지 않습니다.', fields: {} })
  }
  console.error(err)
  res.status(500).json({ code: 'INTERNAL_ERROR', message: '서버 오류가 발생했습니다.', fields: {} })
})