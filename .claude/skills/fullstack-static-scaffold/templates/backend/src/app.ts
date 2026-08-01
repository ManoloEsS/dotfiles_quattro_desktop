import express from 'express'
import mongoose from 'mongoose'
import { info, error as logError } from './utils/logger'
import { MONGODB_URI } from './utils/config'
import { requestLogger, unknownEndpoint, errorHandler } from './utils/middleware'
import { router } from './controllers'

export const app = express()

mongoose.set('strictQuery', false)

info('connecting to MongoDB')

mongoose
    .connect(MONGODB_URI, { family: 4 })
    .then(() => {
        info('connected to MongoDB')
    })
    .catch((err) => {
        logError('error connection to MongoDB:', err.message)
    })

app.use(express.static('dist'))
app.use(express.json())
app.use(requestLogger)

app.use('/', router)

app.use(unknownEndpoint)
app.use(errorHandler)
