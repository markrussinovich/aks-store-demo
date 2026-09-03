extension radius

param environment string
@secure()
param rabbitMqPassword string
@secure()
param rabbitMqUsername string
@secure()
param registryPassword string
@secure()
param registryUsername string

resource aksStoreDemoApp 'Radius.Core/applications@2025-08-01-preview' = {
  name: 'aks-store-demo'
  properties: {
    environment: environment
  }
}

resource mongoDb 'Radius.Data/mongoDatabases@2025-08-01-preview' = {
  name: 'mongo'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/makeline-service/mongodb.go#L149'
    database: 'orderdb'
  }
}

resource rabbitMq 'Radius.Messaging/rabbitMQ@2025-08-01-preview' = {
  name: 'rabbitmq'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/order-service/plugins/messagequeue.js#L26'
    password: rabbitMqPassword
    queue: 'orders'
    username: rabbitMqUsername
  }
}

resource rabbitMqCredentials 'Radius.Security/secrets@2025-08-01-preview' = {
  name: 'rabbitmq-client-credentials'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/order-service/plugins/messagequeue.js#L29'
    data: {
      password: {
        value: rabbitMqPassword
      }
      username: {
        value: rabbitMqUsername
      }
    }
  }
}

resource registryCreds 'Radius.Security/secrets@2025-08-01-preview' = {
  name: 'radius-ghcr-registry-creds'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: '.github/workflows/release-container-images.yaml#L54'
    data: {
      password: {
        value: registryPassword
      }
      username: {
        value: registryUsername
      }
    }
  }
}

resource makelineServiceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'makeline-service-image'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    build: {
      platforms: [
        'linux/amd64'
      ]
      source: 'git::https://github.com/markrussinovich/aks-store-demo.git//src/makeline-service?ref=0e254cc3f9837cf03e1b165db01768e012e0aace'
    }
    codeReference: 'src/makeline-service/Dockerfile#L1'
    tag: 'sha-0e254cc3f983'
  }
  dependsOn: [
    registryCreds
  ]
}

resource orderServiceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'order-service-image'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    build: {
      platforms: [
        'linux/amd64'
      ]
      source: 'git::https://github.com/markrussinovich/aks-store-demo.git//src/order-service?ref=0e254cc3f9837cf03e1b165db01768e012e0aace'
    }
    codeReference: 'src/order-service/Dockerfile#L1'
    tag: 'sha-0e254cc3f983'
  }
  dependsOn: [
    registryCreds
  ]
}

resource productServiceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'product-service-image'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    build: {
      platforms: [
        'linux/amd64'
      ]
      source: 'git::https://github.com/markrussinovich/aks-store-demo.git//src/product-service?ref=0e254cc3f9837cf03e1b165db01768e012e0aace'
    }
    codeReference: 'src/product-service/Dockerfile#L1'
    tag: 'sha-0e254cc3f983'
  }
  dependsOn: [
    registryCreds
  ]
}

resource storeAdminImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'store-admin-image'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    build: {
      platforms: [
        'linux/amd64'
      ]
      source: 'git::https://github.com/markrussinovich/aks-store-demo.git//src/store-admin?ref=0e254cc3f9837cf03e1b165db01768e012e0aace'
    }
    codeReference: 'src/store-admin/Dockerfile#L1'
    tag: 'sha-0e254cc3f983'
  }
  dependsOn: [
    registryCreds
  ]
}

resource storeFrontImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'store-front-image'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    build: {
      platforms: [
        'linux/amd64'
      ]
      source: 'git::https://github.com/markrussinovich/aks-store-demo.git//src/store-front?ref=0e254cc3f9837cf03e1b165db01768e012e0aace'
    }
    codeReference: 'src/store-front/Dockerfile#L1'
    tag: 'sha-0e254cc3f983'
  }
  dependsOn: [
    registryCreds
  ]
}

resource virtualCustomerImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'virtual-customer-image'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    build: {
      platforms: [
        'linux/amd64'
      ]
      source: 'git::https://github.com/markrussinovich/aks-store-demo.git//src/virtual-customer?ref=0e254cc3f9837cf03e1b165db01768e012e0aace'
    }
    codeReference: 'src/virtual-customer/Dockerfile#L1'
    tag: 'sha-0e254cc3f983'
  }
  dependsOn: [
    registryCreds
  ]
}

resource virtualWorkerImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'virtual-worker-image'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    build: {
      platforms: [
        'linux/amd64'
      ]
      source: 'git::https://github.com/markrussinovich/aks-store-demo.git//src/virtual-worker?ref=0e254cc3f9837cf03e1b165db01768e012e0aace'
    }
    codeReference: 'src/virtual-worker/Dockerfile#L1'
    tag: 'sha-0e254cc3f983'
  }
  dependsOn: [
    registryCreds
  ]
}

resource makelineServiceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'makeline'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/makeline-service/main.go#L21'
    connections: {
      mongodb: {
        disableDefaultEnvVars: true
        source: mongoDb.id
      }
      rabbitmq: {
        disableDefaultEnvVars: true
        source: rabbitMq.id
      }
      rabbitmqCredentials: {
        disableDefaultEnvVars: true
        source: rabbitMqCredentials.id
      }
    }
    containers: {
      service: {
        image: makelineServiceImage.properties.imageReference
        env: {
          ORDER_DB_COLLECTION_NAME: {
            value: 'orders'
          }
          ORDER_DB_NAME: {
            value: 'orderdb'
          }
          ORDER_DB_URI: {
            valueFrom: {
              secretKeyRef: {
                key: 'connectionString'
                secretName: mongoDb.properties.secrets.name
              }
            }
          }
          ORDER_QUEUE_NAME: {
            value: 'orders'
          }
          ORDER_QUEUE_PASSWORD: {
            valueFrom: {
              secretKeyRef: {
                key: 'password'
                secretName: rabbitMqCredentials.name
              }
            }
          }
          ORDER_QUEUE_URI: {
            value: 'amqp://${rabbitMq.properties.host}:${rabbitMq.properties.port}'
          }
          ORDER_QUEUE_USERNAME: {
            valueFrom: {
              secretKeyRef: {
                key: 'username'
                secretName: rabbitMqCredentials.name
              }
            }
          }
        }
        livenessProbe: {
          httpGet: {
            path: '/liveness'
            port: 3001
          }
        }
        ports: {
          web: {
            containerPort: 3001
          }
        }
        readinessProbe: {
          httpGet: {
            path: '/health'
            port: 3001
          }
        }
      }
    }
    restartPolicy: 'Always'
  }
}

resource orderServiceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'order'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/order-service/app.js#L6'
    connections: {
      rabbitmq: {
        disableDefaultEnvVars: true
        source: rabbitMq.id
      }
      rabbitmqCredentials: {
        disableDefaultEnvVars: true
        source: rabbitMqCredentials.id
      }
    }
    containers: {
      service: {
        image: orderServiceImage.properties.imageReference
        env: {
          ORDER_QUEUE_HOSTNAME: {
            value: rabbitMq.properties.host
          }
          ORDER_QUEUE_NAME: {
            value: 'orders'
          }
          ORDER_QUEUE_PASSWORD: {
            valueFrom: {
              secretKeyRef: {
                key: 'password'
                secretName: rabbitMqCredentials.name
              }
            }
          }
          ORDER_QUEUE_PORT: {
            value: '${rabbitMq.properties.port}'
          }
          ORDER_QUEUE_USERNAME: {
            valueFrom: {
              secretKeyRef: {
                key: 'username'
                secretName: rabbitMqCredentials.name
              }
            }
          }
        }
        livenessProbe: {
          httpGet: {
            path: '/health'
            port: 3000
          }
        }
        ports: {
          web: {
            containerPort: 3000
          }
        }
        readinessProbe: {
          httpGet: {
            path: '/health'
            port: 3000
          }
        }
      }
    }
    restartPolicy: 'Always'
  }
}

resource productServiceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'product'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/product-service/src/main.rs#L5'
    containers: {
      service: {
        image: productServiceImage.properties.imageReference
        ports: {
          web: {
            containerPort: 3002
          }
        }
        livenessProbe: {
          httpGet: {
            path: '/health'
            port: 3002
          }
        }
        readinessProbe: {
          httpGet: {
            path: '/health'
            port: 3002
          }
        }
      }
    }
    restartPolicy: 'Always'
  }
}

resource storeAdminContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'store-admin'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/store-admin/nginx.conf#L2'
    connections: {
      makelineService: {
        disableDefaultEnvVars: true
        source: makelineServiceContainer.id
      }
      productService: {
        disableDefaultEnvVars: true
        source: productServiceContainer.id
      }
    }
    containers: {
      storeAdmin: {
        image: storeAdminImage.properties.imageReference
        livenessProbe: {
          httpGet: {
            path: '/health'
            port: 8081
          }
        }
        ports: {
          web: {
            containerPort: 8081
          }
        }
        readinessProbe: {
          httpGet: {
            path: '/health'
            port: 8081
          }
        }
      }
    }
    restartPolicy: 'Always'
  }
}

resource storeFrontContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'store-front'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/store-front/nginx.conf#L2'
    connections: {
      orderService: {
        disableDefaultEnvVars: true
        source: orderServiceContainer.id
      }
      productService: {
        disableDefaultEnvVars: true
        source: productServiceContainer.id
      }
    }
    containers: {
      storeFront: {
        image: storeFrontImage.properties.imageReference
        livenessProbe: {
          httpGet: {
            path: '/health'
            port: 8080
          }
        }
        ports: {
          web: {
            containerPort: 8080
          }
        }
        readinessProbe: {
          httpGet: {
            path: '/health'
            port: 8080
          }
        }
      }
    }
    restartPolicy: 'Always'
  }
}

resource virtualCustomerContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'virtual-customer'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/virtual-customer/src/main.rs#L7'
    connections: {
      orderService: {
        disableDefaultEnvVars: true
        source: orderServiceContainer.id
      }
    }
    containers: {
      virtualCustomer: {
        image: virtualCustomerImage.properties.imageReference
        env: {
          ORDERS_PER_HOUR: {
            value: '30'
          }
          ORDER_SERVICE_URL: {
            value: 'http://${orderServiceContainer.properties.hosts.service}:3000/'
          }
        }
      }
    }
    restartPolicy: 'Always'
  }
}

resource virtualWorkerContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'virtual-worker'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/virtual-worker/src/main.rs#L6'
    connections: {
      makelineService: {
        disableDefaultEnvVars: true
        source: makelineServiceContainer.id
      }
    }
    containers: {
      virtualWorker: {
        image: virtualWorkerImage.properties.imageReference
        env: {
          MAKELINE_SERVICE_URL: {
            value: 'http://${makelineServiceContainer.properties.hosts.service}:3001'
          }
          ORDERS_PER_HOUR: {
            value: '20'
          }
        }
      }
    }
    restartPolicy: 'Always'
  }
}
