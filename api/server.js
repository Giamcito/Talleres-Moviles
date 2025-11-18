// Simple Express in-memory API for tasks with LWW conflict handling.
const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const bodyParser = require('body-parser');
const { v4: uuid } = require('uuid');

const PORT = process.env.PORT || 3000;
const app = express();
app.use(cors());
app.use(morgan('dev'));
app.use(bodyParser.json());

// In-memory store
let tasks = []; // {id, title, completed, updatedAt}

// Helper: find task index
function findIndex(id) { return tasks.findIndex(t => t.id === id); }

// GET /tasks
app.get('/tasks', (req, res) => {
  res.json(tasks);
});

// POST /tasks
app.post('/tasks', (req, res) => {
  const { id, title, completed, updatedAt } = req.body;
  if (!id || !title || !updatedAt) {
    return res.status(400).json({ error: 'Campos requeridos: id, title, updatedAt' });
  }
  const idx = findIndex(id);
  if (idx >= 0) {
    // LWW: si viene updatedAt más reciente, reemplazar
    if (new Date(updatedAt) > new Date(tasks[idx].updatedAt)) {
      tasks[idx] = { id, title, completed: !!completed, updatedAt };
    }
  } else {
    tasks.push({ id, title, completed: !!completed, updatedAt });
  }
  res.status(201).json({ ok: true });
});

// GET /tasks/:id
app.get('/tasks/:id', (req, res) => {
  const idx = findIndex(req.params.id);
  if (idx < 0) return res.status(404).json({ error: 'Not found' });
  res.json(tasks[idx]);
});

// PUT /tasks/:id
app.put('/tasks/:id', (req, res) => {
  const { title, completed, updatedAt } = req.body;
  if (!updatedAt) return res.status(400).json({ error: 'updatedAt requerido' });
  const idx = findIndex(req.params.id);
  if (idx < 0) return res.status(404).json({ error: 'Not found' });
  // LWW
  if (new Date(updatedAt) > new Date(tasks[idx].updatedAt)) {
    tasks[idx] = { ...tasks[idx], title: title ?? tasks[idx].title, completed: completed ?? tasks[idx].completed, updatedAt };
  }
  res.json({ ok: true });
});

// DELETE /tasks/:id
app.delete('/tasks/:id', (req, res) => {
  const idx = findIndex(req.params.id);
  if (idx < 0) return res.status(404).json({ error: 'Not found' });
  tasks.splice(idx, 1);
  res.json({ ok: true });
});

// Seed endpoint (optional)
app.post('/seed', (req, res) => {
  tasks = [
    { id: uuid(), title: 'Tarea inicial', completed: false, updatedAt: new Date().toISOString() },
    { id: uuid(), title: 'Explorar arquitectura', completed: false, updatedAt: new Date().toISOString() },
  ];
  res.json({ ok: true, count: tasks.length });
});

app.listen(PORT, () => console.log(`Mock API escuchando en puerto ${PORT}`));
