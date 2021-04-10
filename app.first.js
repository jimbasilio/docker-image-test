const express = require('express')
const app = express()

app.get('/', (req, res) => res.send('Hello World AGAIN!'))
app.listen(3000, () => console.log('Server ready and this is different'))
