# Trendz Analytics - Installation Guide on Windows

Trendz is a powerful data analytics tool integrated into the ThingsBoard/CoreIoT ecosystem. This guide helps you install and configure Trendz on Windows.

---

## ⚙️ System Requirements

- Windows 10/11 (64-bit)
- Java 17 (OpenJDK)
- PostgreSQL 12 or later
- PowerShell (with administrator rights)
- VS Code or equivalent editor

---

## 🚀 Installation Steps

### Step 1. Install Java 17 (OpenJDK)

1. Visit [Adoptium.net](https://adoptium.net/)
2. Select:
   - OS: Windows
   - Architecture: x64
   - Version: 17 (LTS)
3. Download and install the `.msi` file. Make sure to:
   - ✅ Add to PATH
   - ✅ Set JAVA_HOME variable
4. Download the [PostgreSQL JDBC Driver](https://jdbc.postgresql.org/download/)
5. Create the directory `C:\Program Files\JDBC` and copy the `.jar` file there.
6. Run PowerShell as Administrator and enter:
   ```powershell
   [System.Environment]::SetEnvironmentVariable("CLASSPATH", '.;"C:\Program Files\JDBC\postgresql-42.2.18.jar"', [System.EnvironmentVariableTarget]::Machine)
   ```

---

### Step 2. Install Trendz Analytics

- Download from: [`https://dist.thingsboard.io/trendz-windows-1.13.1.zip`](https://dist.thingsboard.io/trendz-windows-1.13.1.zip)
- Extract to: `C:\Program Files (x86)\trendz`

---

### Step 3. Configure License

1. Visit the [license page](https://thingsboard.io/pricing/?section=trendz-options&product=trendz-self-managed&solution=trendz-pay-as-you-go) to obtain your `license secret`.
2. Open the config file:

   ```
   C:\Program Files (x86)\trendz\conf\trendz.yml
   ```

3. Paste the license secret in the relevant configuration section.

---

### Step 4. Connect to CoreIoT (ThingsBoard)

1. Open `trendz.yml` with admin rights.
2. Locate the REST API URL setting, e.g.:

   ```yaml
   api_url: http://localhost:8080
   ```

---

### Step 5. Configure Database

#### Install PostgreSQL

- Download from: [PostgreSQL Downloads](https://www.enterprisedb.com/downloads/postgres-postgresql-downloads#windows)

#### Create the Trendz Database

1. Open `pgAdmin` and log in with the `postgres` user.
2. Create a new database:
   - Name: `trendz`  
   - Owner: `postgres`

#### Update database configuration

Edit the following block in `trendz.yml`:

```yaml
datasource:
  driverClassName: "${SPRING_DRIVER_CLASS_NAME:org.postgresql.Driver}"
  url: "${SPRING_DATASOURCE_URL:jdbc:postgresql://localhost:5432/trendz}"
  username: "${SPRING_DATASOURCE_USERNAME:postgres}"
  password: "${SPRING_DATASOURCE_PASSWORD:postgres}"
  hikari:
    maximumPoolSize: "${SPRING_DATASOURCE_MAXIMUM_POOL_SIZE:5}"
```

---

### Step 6. Install Trendz as a Windows Service

```bash
cd "C:\Program Files (x86)\trendz"
install.bat
```

---

### Step 7. Start the Trendz Service

```bash
net start trendz
```

✅ To restart:

```bash
net stop trendz
net start trendz
```

---

## 🌐 Access the Trendz Web Interface

- Default: [http://localhost:8888/trendz](http://localhost:8888/trendz)

---

## 📊 Sample Results from Trendz

### Topology Visualization

![Topology](HÌNH%20ẢNH/topoly.png)

---

### Temperature & Humidity Forecast

![Temperature & Humidity Forecast](HÌNH%20ẢNH/predict.png)

---

### TVOC Prediction Model

![TVOC Prediction](HÌNH%20ẢNH/trendz_predict.png)
