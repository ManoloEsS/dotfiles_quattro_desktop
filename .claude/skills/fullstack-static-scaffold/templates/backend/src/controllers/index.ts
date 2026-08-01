import express, { Response, Request, NextFunction } from 'express'
import { Item } from '../models/item'

export const router = express.Router()

router.get('/', (_req: Request, res: Response) => {
    res.json({ message: 'API is running' })
})

router.get('/health', (_req: Request, res: Response) => {
    res.json({ status: 'ok' })
})

router.get('/api/items', (_req: Request, res: Response) => {
    Item.find({}).then((items) => {
        res.json(items)
    })
})

router.get('/info', (_req: Request, res: Response) => {
    const currTime = new Date()
    res.type('text/html')
    Item.find({}).then((items) => {
        const info = `<p>Phonebook has info for ${items.length} people</p>
<p>${currTime.toString()}</p>`
        res.send(info)
    })
})

router.get('/api/items/:id', (req: Request, res: Response, next: NextFunction) => {
    const id = req.params.id
    Item.findById(id)
        .then((item) => {
            if (item) {
                return res.json(item)
            } else {
                res.sendStatus(404).end()
            }
        })
        .catch((error) => next(error))
})

router.delete('/api/items/:id', (req: Request, res: Response, next: NextFunction) => {
    const id = req.params.id
    Item.findByIdAndDelete(id)
        .then(() => {
            res.sendStatus(204).end()
        })
        .catch((error) => next(error))
})

router.post('/api/items/', (req: Request, res: Response, next: NextFunction) => {
    const itemData = req.body

    const newItem = new Item({
        name: itemData.name,
        number: itemData.number,
    })

    newItem.save()
        .then((savedItem) => {
            res.json(savedItem)
        })
        .catch((error) => next(error))
})

router.put('/api/items/:id', (req: Request, res: Response, next: NextFunction) => {
    const itemId = req.params.id
    const itemData = req.body

    Item.findById(itemId)
        .then((itemToUpdate) => {
            if (itemToUpdate) {
                itemToUpdate.name = itemData.name ?? itemToUpdate.name
                itemToUpdate.number = itemData.number ?? itemToUpdate.number
                return itemToUpdate.save()
                    .then((updatedData) => {
                        res.json(updatedData)
                    })
            } else {
                res.status(400).json({
                    error: 'item does not exist in db',
                })
            }
        })
        .catch((error) => next(error))
})
