import mongoose from 'mongoose'

const itemSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true,
        minLength: 3,
    },
    number: {
        type: String,
    },
})

itemSchema.set('toJSON', {
    transform: (_doc: mongoose.Document, ret: Record<string, unknown>) => {
        ret.id = (ret._id as mongoose.Types.ObjectId).toString()
        delete ret._id
        delete ret.__v
    },
})

export const Item = mongoose.model('Item', itemSchema)
