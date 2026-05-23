# RAG — Chat with Your Documents / Chatear con tus Documentos

## EN

### What is RAG?
RAG (Retrieval-Augmented Generation) lets you chat with your own documents. The model searches through your files to find relevant information before answering.

### Setup
1. Open WebUI supports RAG natively
2. Go to Workspace → Documents
3. Upload your files (PDF, TXT, Markdown)
4. In any chat, type `@` to reference documents
5. The model will search and use them as context

### Supported Formats
- PDF
- TXT
- Markdown
- Code files (auto-detected)

### Tips
- Use `nomic-embed-text` model for embeddings (auto-configured)
- Upload related documents together for better context
- For technical manuals, upload the full document and ask specific questions
- RAG works with all 5 Ollama models

## ES

### ¿Qué es RAG?
RAG (Retrieval-Augmented Generation) te permite chatear con tus propios documentos. El modelo busca en tus archivos información relevante antes de responder.

### Configuración
1. Open WebUI soporta RAG de forma nativa
2. Ve a Workspace → Documentos
3. Sube tus archivos (PDF, TXT, Markdown)
4. En cualquier chat, escribe `@` para referenciar documentos
5. El modelo buscará y los usará como contexto

### Formatos Soportados
- PDF
- TXT
- Markdown
- Archivos de código (detección automática)

### Consejos
- Usa el modelo `nomic-embed-text` para embeddings (configuración automática)
- Sube documentos relacionados juntos para mejor contexto
- Para manuales técnicos, sube el documento completo y haz preguntas específicas
- RAG funciona con los 5 modelos de Ollama
