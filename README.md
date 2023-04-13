# Ckan Indexa Docker
This is a CKAN custom docker-compose build for [Indexa Geodata Catalogue](http://catalogo.indexageodata.com). Ckan version used is 2.9.5.
## Deploy
1. Create a .env file. You can use default .env.template but it's not recommended for production.
```
     cp .env.template .env
```
2. Use docker-compose to run CKAN.
	
```
	docker-compose up --build
```
