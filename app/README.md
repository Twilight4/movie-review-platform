# Movie Review Starter API
This is the starter application for the DevOps project.

## Movie-review (api-node)

### api-node
```bash
# Check node and npm versions
node -v
npm -v

# Install dependencies
go-task install

# Run node server
go-task start

# Run tests
go-task test

# Start node dev mode
go-task run
```

## Testing endpoints
```bash
# GET /movies - Returns list of movies
xh http://127.0.0.1:3000/movies

# POST /movies - Adds a movie
xh post http://localhost:3000/movies title="Avatar 2" rating:=4
xh http://127.0.0.1:3000/movies

# GET /health - For Kubernetes probes
xh get http://localhost:3000/health
```