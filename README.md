K8s secrets.yaml

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secrets
type: Opaque
data:
  username: _____(base64)
  password: _____(base64)
  db: _____(base64)
```

# Microservices with Vaadin demo application

## Build the app

Run the following from the command line:

```
git clone https://github.com/momerkic/demo-app.git
cd demo-app
mvn clean install
```

## Running the app/services

Ensure that postgresql-10 is running. Create user demo with password 'demo'. Create database 'demo' with owner demo.

Use multiple terminals to perform the following steps:

**1) Start an instance of the `biz-application` microservice (REST app):**

```
cd demo-app/biz-application
java -jar target/biz-application-0.0.1-SNAPSHOT.jar
```

**2) Start an instance of the `admin-application` microservice (Vaadin app):**

```
cd demo-app/admin-application
java -jar target/admin-application-0.0.1-SNAPSHOT.jar
```

**3) Start an instance of the `news-application` microservice (Vaadin app):**

```
cd demo-app/news-application
java -jar target/news-application-0.0.1-SNAPSHOT.jar
```

**4) Start an instance of the `website-application` microservice (Vaadin app):**

```
cd demo-app/website-application
java -jar target/website-application-0.0.1-SNAPSHOT.jar
```

## Using the app

**1) Point your browser to <http://localhost:9301/ui/>.**

You'll see the `website-application` embedding the `admin-application` and the `news-application` microservices.

**2) Add, update, or delete data.**

Latest tweets from the companies you enter on the left (the `admin-application`) will be rendered on the right (the `news-application`).

The `admin-application`, and `news-application` instances (implemented with Vaadin) delegate CRUD operations to the `biz-application`.
