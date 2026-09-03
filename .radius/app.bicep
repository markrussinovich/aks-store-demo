extension radius

param environment string

@secure()
param rabbitMqPassword string

@secure()
param registryPassword string

@secure()
param registryUsername string

var serviceContainerKey = 'service'

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
    codeReference: 'src/makeline-service/mongodb.go#L134'
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
    username: 'username'
  }
}

resource rabbitMqCredentials 'Radius.Security/secrets@2025-08-01-preview' = {
  name: 'rabbitmq-credentials'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/order-service/plugins/messagequeue.js#L29'
    data: {
      password: {
        value: rabbitMqPassword
      }
    }
  }
}

resource registryCredentials 'Radius.Security/secrets@2025-08-01-preview' = {
  name: 'radius-ghcr-registry-creds'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: '.github/workflows/run-rad-commands-azure.yml#L233'
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
    codeReference: 'src/makeline-service/Dockerfile#L1'
    tag: '86acd34c8b2f5f01'
    build: {
      source: 'git::https://github.com/markrussinovich/aks-store-demo.git//src/makeline-service?ref=86acd34c8b2f5f01cf07adcc79eda7068566d3e2'
      platforms: [
        'linux/amd64'
      ]
    }
  }
  dependsOn: [
    registryCredentials
  ]
}

resource orderServiceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'order-service-image'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/order-service/Dockerfile#L1'
    tag: '86acd34c8b2f5f01'
    build: {
      source: 'git::https://github.com/markrussinovich/aks-store-demo.git//src/order-service?ref=86acd34c8b2f5f01cf07adcc79eda7068566d3e2'
      platforms: [
        'linux/amd64'
      ]
    }
  }
  dependsOn: [
    registryCredentials
  ]
}

resource productServiceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'product-service-image'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/product-service/Dockerfile#L1'
    tag: '86acd34c8b2f5f01'
    build: {
      source: 'git::https://github.com/markrussinovich/aks-store-demo.git//src/product-service?ref=86acd34c8b2f5f01cf07adcc79eda7068566d3e2'
      platforms: [
        'linux/amd64'
      ]
    }
  }
  dependsOn: [
    registryCredentials
  ]
}

resource storeAdminImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'store-admin-image'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/store-admin/Dockerfile#L1'
    tag: '86acd34c8b2f5f01'
    build: {
      source: 'git::https://github.com/markrussinovich/aks-store-demo.git//src/store-admin?ref=86acd34c8b2f5f01cf07adcc79eda7068566d3e2'
      platforms: [
        'linux/amd64'
      ]
    }
  }
  dependsOn: [
    registryCredentials
  ]
}

resource storeFrontImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'store-front-image'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/store-front/Dockerfile#L1'
    tag: '86acd34c8b2f5f01'
    build: {
      source: 'git::https://github.com/markrussinovich/aks-store-demo.git//src/store-front?ref=86acd34c8b2f5f01cf07adcc79eda7068566d3e2'
      platforms: [
        'linux/amd64'
      ]
    }
  }
  dependsOn: [
    registryCredentials
  ]
}

resource virtualCustomerImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'virtual-customer-image'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/virtual-customer/Dockerfile#L1'
    tag: '86acd34c8b2f5f01'
    build: {
      source: 'git::https://github.com/markrussinovich/aks-store-demo.git//src/virtual-customer?ref=86acd34c8b2f5f01cf07adcc79eda7068566d3e2'
      platforms: [
        'linux/amd64'
      ]
    }
  }
  dependsOn: [
    registryCredentials
  ]
}

resource virtualWorkerImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'virtual-worker-image'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/virtual-worker/Dockerfile#L1'
    tag: '86acd34c8b2f5f01'
    build: {
      source: 'git::https://github.com/markrussinovich/aks-store-demo.git//src/virtual-worker?ref=86acd34c8b2f5f01cf07adcc79eda7068566d3e2'
      platforms: [
        'linux/amd64'
      ]
    }
  }
  dependsOn: [
    registryCredentials
  ]
}

resource makelineServiceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'makeline'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/makeline-service/main.go#L21'
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
                secretName: mongoDb.properties.secrets.name
                key: 'connectionString'
              }
            }
          }
          ORDER_QUEUE_NAME: {
            value: 'orders'
          }
          ORDER_QUEUE_PASSWORD: {
            valueFrom: {
              secretKeyRef: {
                secretName: rabbitMqCredentials.name
                key: 'password'
              }
            }
          }
          ORDER_QUEUE_URI: {
            value: 'amqp://${rabbitMq.properties.host}:${rabbitMq.properties.port}'
          }
          ORDER_QUEUE_USERNAME: {
            value: 'username'
          }
        }
        ports: {
          web: {
            containerPort: 3001
          }
        }
        livenessProbe: {
          httpGet: {
            path: '/liveness'
            port: 3001
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
    connections: {
      mongo: {
        source: mongoDb.id
        disableDefaultEnvVars: true
      }
      rabbitmq: {
        source: rabbitMq.id
        disableDefaultEnvVars: true
      }
      rabbitmqCredentials: {
        source: rabbitMqCredentials.id
        disableDefaultEnvVars: true
      }
    }
  }
}

resource orderServiceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'order'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/order-service/app.js#L6'
    containers: {
      service: {
        image: orderServiceImage.properties.imageReference
        env: {
          FASTIFY_ADDRESS: {
            value: '0.0.0.0'
          }
          ORDER_QUEUE_HOSTNAME: {
            value: rabbitMq.properties.host
          }
          ORDER_QUEUE_NAME: {
            value: 'orders'
          }
          ORDER_QUEUE_PASSWORD: {
            valueFrom: {
              secretKeyRef: {
                secretName: rabbitMqCredentials.name
                key: 'password'
              }
            }
          }
          ORDER_QUEUE_PORT: {
            value: '${rabbitMq.properties.port}'
          }
          ORDER_QUEUE_USERNAME: {
            value: 'username'
          }
        }
        ports: {
          web: {
            containerPort: 3000
          }
        }
        livenessProbe: {
          httpGet: {
            path: '/health'
            port: 3000
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
    connections: {
      rabbitmq: {
        source: rabbitMq.id
        disableDefaultEnvVars: true
      }
      rabbitmqCredentials: {
        source: rabbitMqCredentials.id
        disableDefaultEnvVars: true
      }
    }
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
  }
}

resource storeAdminContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'store-admin'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/store-admin/nginx.conf#L1'
    containers: {
      web: {
        image: storeAdminImage.properties.imageReference
        ports: {
          web: {
            containerPort: 8081
          }
        }
        livenessProbe: {
          httpGet: {
            path: '/health'
            port: 8081
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
    connections: {
      makeline: {
        source: makelineServiceContainer.id
        disableDefaultEnvVars: true
      }
      product: {
        source: productServiceContainer.id
        disableDefaultEnvVars: true
      }
    }
  }
}

resource storeFrontContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'store-front'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/store-front/nginx.conf#L1'
    containers: {
      web: {
        image: storeFrontImage.properties.imageReference
        ports: {
          web: {
            containerPort: 8080
          }
        }
        livenessProbe: {
          httpGet: {
            path: '/health'
            port: 8080
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
    connections: {
      order: {
        source: orderServiceContainer.id
        disableDefaultEnvVars: true
      }
      product: {
        source: productServiceContainer.id
        disableDefaultEnvVars: true
      }
    }
  }
}

resource virtualCustomerContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'virtual-customer'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/virtual-customer/src/main.rs#L7'
    containers: {
      worker: {
        image: virtualCustomerImage.properties.imageReference
        env: {
          ORDERS_PER_HOUR: {
            value: '20'
          }
          ORDER_SERVICE_URL: {
            value: 'http://${orderServiceContainer.properties.hosts[serviceContainerKey]}:3000/'
          }
        }
      }
    }
    connections: {
      order: {
        source: orderServiceContainer.id
        disableDefaultEnvVars: true
      }
    }
  }
}

resource virtualWorkerContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'virtual-worker'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/virtual-worker/src/main.rs#L6'
    containers: {
      worker: {
        image: virtualWorkerImage.properties.imageReference
        env: {
          MAKELINE_SERVICE_URL: {
            value: 'http://${makelineServiceContainer.properties.hosts[serviceContainerKey]}:3001'
          }
          ORDERS_PER_HOUR: {
            value: '10'
          }
        }
      }
    }
    connections: {
      makeline: {
        source: makelineServiceContainer.id
        disableDefaultEnvVars: true
      }
    }
  }
}

resource storeAdminRoute 'Radius.Compute/routes@2025-08-01-preview' = {
  name: 'store-admin'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'charts/aks-store-demo/templates/store-admin.yaml#L53'
    kind: 'HTTP'
    rules: [
      {
        destinationContainer: {
          resourceId: storeAdminContainer.id
          containerName: 'web'
          containerPort: 8081
        }
        matches: [
          {
            httpPath: '/'
          }
        ]
      }
    ]
  }
}

resource storeFrontRoute 'Radius.Compute/routes@2025-08-01-preview' = {
  name: 'store-front'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'charts/aks-store-demo/templates/store-front.yaml#L53'
    kind: 'HTTP'
    rules: [
      {
        destinationContainer: {
          resourceId: storeFrontContainer.id
          containerName: 'web'
          containerPort: 8080
        }
        matches: [
          {
            httpPath: '/'
          }
        ]
      }
    ]
  }
}
