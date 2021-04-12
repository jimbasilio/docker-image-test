const express = require('express')
const app = express()

app.get('/', (req, res) => res.send('BASE'))
app.listen(3000, () => console.log('BASE ready'))
