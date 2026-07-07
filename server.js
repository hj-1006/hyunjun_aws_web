import express from 'express';
import bodyParser from 'body-parser';
import cors from 'cors';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const PORT = 1006;
let count = 0;

const app = express();
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

app.use(express.static(path.join(__dirname, 'public')));

app.get('/api/getCount', (req,res)=>{
    console.log(`[${new Date().toISOString()}] count: ${count}`);
    res.json({ count: count });
})

app.put('/api/putCount', (req,res)=>{
    count = req.body.count;
    count++;
    console.log(`[${new Date().toISOString()}] count: ${count}`);
    res.json({ count: count });
})

app.listen(PORT, () => {
    console.log(`Hyunjun's Server is running on port ${PORT}`);
});

export default app;