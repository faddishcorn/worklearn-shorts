import { db } from '../src/db.js'
import { hashPassword } from '../src/lib/password.js'

const { ADMIN_USERNAME, ADMIN_PASSWORD } = process.env
if (!ADMIN_USERNAME || !ADMIN_PASSWORD) {
  console.error('backend/.env에 ADMIN_USERNAME, ADMIN_PASSWORD를 설정하세요.')
  process.exit(1)
}

const exists = db.prepare('SELECT id FROM admins WHERE username = ?').get(ADMIN_USERNAME)
if (exists) {
  console.log('관리자 계정이 이미 있어 건너뜁니다:', ADMIN_USERNAME)
} else {
  db.prepare('INSERT INTO admins (username, password_hash) VALUES (?, ?)')
    .run(ADMIN_USERNAME, hashPassword(ADMIN_PASSWORD))
  console.log('관리자 계정 생성:', ADMIN_USERNAME)
}

for (const name of ['엑셀', '개발', '업무자동화', '비즈니스 매너']) {
  db.prepare('INSERT OR IGNORE INTO tags (name) VALUES (?)').run(name)
}
console.log('기본 태그 준비 완료')