const express = require('express')
const app = express()

app.use('/', (req, res) => res.redirect('/blog'))
app.use('/blog', express.static('_book'))
app.use('/etop', express.static('etop/_book'))

const PORT = process.env.PORT || 3000
app.listen(PORT, () => console.log(`Listening on ${ PORT }`))
