const express = require('express')
const app = express()

app.get('/', (req, res) => res.send('BASE PATCHED'))
app.listen(3000, () => console.log('BASE PATCHED ready'))
