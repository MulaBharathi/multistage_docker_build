# Build the Docker image
```
docker build -t flask-app:prod .
```


# Run the container
```
docker run -p 5000:5000 flask-app:prod
```
