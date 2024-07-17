FROM node:alpine AS development

# Setting up the work directory
WORKDIR /react-app

# Installing dependencies
COPY ./react-shop/package*.json /react-app

RUN npm install

# Copying all the files in our project
COPY ./react-shop/ .

# Starting our application
CMD ["npm","start"]