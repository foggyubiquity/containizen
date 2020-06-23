let gid = process.getgid()
let uid = process.getuid()

console.log('GID: ' + gid)
console.log('UID: ' + uid)

if (gid === 328 && uid === 289)
	console.log('Hello, world!')
else
	console.log("Root says Hello")
