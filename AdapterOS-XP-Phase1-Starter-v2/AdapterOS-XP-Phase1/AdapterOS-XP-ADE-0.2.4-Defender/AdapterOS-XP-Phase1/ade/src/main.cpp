#include <QCoreApplication>
#include <QDateTime>
#include <QCryptographicHash>
#include <QJsonDocument>
#include <QJsonObject>
#include <QSaveFile>
#include <QHash>
#include <QUuid>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QGuiApplication>
#include <QProcess>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QRegularExpression>
#include <QStorageInfo>
#include <QSysInfo>
#include <QStringList>
#include <QTime>
#include <QUrl>
#include <QVariantList>
#include <QVariantMap>
#include <cerrno>
#include <csignal>
#include <unistd.h>

class AdeBackend final : public QObject
{
    Q_OBJECT

public:
    using QObject::QObject;

    Q_INVOKABLE QString executeCommand(const QString &input) const
    {
        QString cleaned = input.trimmed();
        if (cleaned.isEmpty())
            return QString();

        QStringList parts = cleaned.split(QRegularExpression(QStringLiteral("\\s+")), Qt::SkipEmptyParts);
        if (parts.first().compare(QStringLiteral("ade"), Qt::CaseInsensitive) == 0)
            parts.removeFirst();

        if (parts.isEmpty())
            return helpText();

        const QString command = parts.at(0).toLower();
        const QString argument = parts.size() > 1 ? parts.at(1).toLower() : QString();

        if (command == QStringLiteral("help"))
            return helpText();

        if (command == QStringLiteral("about") || command == QStringLiteral("version"))
            return QStringLiteral("AdapterOS XP 0.2.4\nADE — Adapter Desktop Environment\nA Debian 13 based desktop project.");

        if (command == QStringLiteral("games"))
            return QStringLiteral("BUILT-IN GAMES\n  Snake       - Classic snake arcade game\n\nTry: launch snake");

        if (command == QStringLiteral("tasks") || command == QStringLiteral("taskmgr") || command == QStringLiteral("taskmanager"))
            return QStringLiteral("@ACTION:taskmgr");
        if (command == QStringLiteral("sysinfo"))
            return QStringLiteral("@ACTION:sysinfo");
        if (command == QStringLiteral("disk"))
            return QStringLiteral("@ACTION:disk");
        if (command == QStringLiteral("network"))
            return QStringLiteral("@ACTION:network");
        if (command == QStringLiteral("clock"))
            return QStringLiteral("@ACTION:clock");
        if (command == QStringLiteral("utilities"))
            return QStringLiteral("@ACTION:utilities");
        if (command == QStringLiteral("defender") || command == QStringLiteral("security"))
            return QStringLiteral("@ACTION:defender");

        if (command == QStringLiteral("launch")) {
            static const QStringList allowedApps = {
                QStringLiteral("snake"), QStringLiteral("games"), QStringLiteral("terminal"),
                QStringLiteral("settings"), QStringLiteral("files"), QStringLiteral("notepad"),
                QStringLiteral("calculator"), QStringLiteral("about"), QStringLiteral("taskmgr"),
                QStringLiteral("taskmanager"), QStringLiteral("sysinfo"), QStringLiteral("disk"),
                QStringLiteral("network"), QStringLiteral("clock"), QStringLiteral("utilities"), QStringLiteral("defender")
            };
            if (!allowedApps.contains(argument))
                return QStringLiteral("Unknown app: %1\nRun 'help' to see available commands.").arg(argument);
            if (argument == QStringLiteral("games")) return QStringLiteral("@ACTION:snake");
            if (argument == QStringLiteral("taskmanager")) return QStringLiteral("@ACTION:taskmgr");
            return QStringLiteral("@ACTION:%1").arg(argument);
        }

        if (command == QStringLiteral("theme")) {
            const QString theme = argument;
            if (theme == QStringLiteral("luna") || theme == QStringLiteral("silver")
                || theme == QStringLiteral("olive") || theme == QStringLiteral("classic"))
                return QStringLiteral("@THEME:%1").arg(theme);
            return QStringLiteral("Available themes: luna, silver, olive, classic\nExample: theme luna");
        }

        if (command == QStringLiteral("date"))
            return QDateTime::currentDateTime().toString(QStringLiteral("dddd, d MMMM yyyy"));

        if (command == QStringLiteral("time"))
            return QDateTime::currentDateTime().toString(QStringLiteral("h:mm:ss AP"));

        if (command == QStringLiteral("whoami"))
            return qEnvironmentVariable("USER", "adapteros");

        if (command == QStringLiteral("echo")) {
            parts.removeFirst();
            return parts.join(QLatin1Char(' '));
        }

        if (command == QStringLiteral("sound") && argument == QStringLiteral("test"))
            return QStringLiteral("@ACTION:playsound");

        if (command == QStringLiteral("clear"))
            return QStringLiteral("@CLEAR");

        if (command == QStringLiteral("exit"))
            return QStringLiteral("@ACTION:closeapp");

        return QStringLiteral("'%1' is not an ADE command. Type 'help' to see available commands.").arg(parts.first());
    }

    Q_INVOKABLE QVariantList processList() const
    {
        QProcess ps;
        ps.start(QStringLiteral("/bin/ps"), {
            QStringLiteral("-eo"), QStringLiteral("pid=,comm=,%cpu=,%mem="),
            QStringLiteral("--sort=-%cpu")
        });

        if (!ps.waitForStarted(1200) || !ps.waitForFinished(2500))
            return {};

        const QString output = QString::fromLocal8Bit(ps.readAllStandardOutput());
        const QStringList lines = output.split(QLatin1Char('\n'), Qt::SkipEmptyParts);
        QVariantList rows;
        rows.reserve(qMin(lines.size(), 100));

        for (const QString &line : lines) {
            const QStringList fields = line.trimmed().split(QRegularExpression(QStringLiteral("\\s+")), Qt::SkipEmptyParts);
            if (fields.size() < 4)
                continue;

            bool pidOk = false;
            bool cpuOk = false;
            bool memOk = false;
            const int pid = fields.first().toInt(&pidOk);
            const double cpu = fields.at(fields.size() - 2).toDouble(&cpuOk);
            const double memory = fields.last().toDouble(&memOk);
            if (!pidOk || !cpuOk || !memOk)
                continue;

            const QString name = fields.mid(1, fields.size() - 3).join(QLatin1Char(' '));
            QVariantMap row;
            row.insert(QStringLiteral("pid"), pid);
            row.insert(QStringLiteral("name"), name);
            row.insert(QStringLiteral("cpu"), QString::number(cpu, 'f', 1));
            row.insert(QStringLiteral("memory"), QString::number(memory, 'f', 1));
            rows.append(row);
            if (rows.size() >= 100)
                break;
        }
        return rows;
    }

    Q_INVOKABLE QString terminateProcess(int pid) const
    {
        if (pid <= 1 || pid == static_cast<int>(QCoreApplication::applicationPid()))
            return QStringLiteral("For safety, ADE will not end this protected process.");

        QFile processNameFile(QStringLiteral("/proc/%1/comm").arg(pid));
        if (processNameFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
            const QString processName = QString::fromLocal8Bit(processNameFile.readAll()).trimmed().toLower();
            static const QStringList protectedNames = {
                QStringLiteral("systemd"), QStringLiteral("sddm"), QStringLiteral("kwin_wayland"),
                QStringLiteral("plasmashell"), QStringLiteral("xwayland"), QStringLiteral("weston")
            };
            if (protectedNames.contains(processName))
                return QStringLiteral("For safety, ADE protects this desktop or system process.");
        }

        if (::kill(static_cast<pid_t>(pid), SIGTERM) == 0)
            return QStringLiteral("A close request was sent to process %1.").arg(pid);

        const int errorNumber = errno;
        if (errorNumber == ESRCH)
            return QStringLiteral("Process %1 has already exited.").arg(pid);
        if (errorNumber == EPERM)
            return QStringLiteral("Permission denied. This process belongs to another user or requires administrator privileges.");
        return QStringLiteral("Could not end process %1 (error %2).").arg(pid).arg(errorNumber);
    }

    Q_INVOKABLE QVariantMap systemStats() const
    {
        QVariantMap result;
        result.insert(QStringLiteral("os"), systemName());
        result.insert(QStringLiteral("host"), QSysInfo::machineHostName());
        result.insert(QStringLiteral("kernel"), QSysInfo::kernelVersion());
        result.insert(QStringLiteral("architecture"), QSysInfo::currentCpuArchitecture());
        result.insert(QStringLiteral("cpu"), cpuModel());

        quint64 totalMemory = 0;
        quint64 availableMemory = 0;
        QFile memInfo(QStringLiteral("/proc/meminfo"));
        if (memInfo.open(QIODevice::ReadOnly | QIODevice::Text)) {
            while (!memInfo.atEnd()) {
                const QByteArray line = memInfo.readLine();
                if (line.startsWith("MemTotal:"))
                    totalMemory = line.split(':').value(1).trimmed().split(' ').value(0).toULongLong();
                else if (line.startsWith("MemAvailable:"))
                    availableMemory = line.split(':').value(1).trimmed().split(' ').value(0).toULongLong();
            }
        }

        const quint64 usedMemory = totalMemory > availableMemory ? totalMemory - availableMemory : 0;
        result.insert(QStringLiteral("memoryTotalMb"), static_cast<qulonglong>(totalMemory / 1024));
        result.insert(QStringLiteral("memoryUsedMb"), static_cast<qulonglong>(usedMemory / 1024));
        result.insert(QStringLiteral("memoryAvailableMb"), static_cast<qulonglong>(availableMemory / 1024));
        result.insert(QStringLiteral("memoryPercent"), totalMemory ? qRound((double(usedMemory) / double(totalMemory)) * 100.0) : 0);

        QFile uptimeFile(QStringLiteral("/proc/uptime"));
        double uptimeSeconds = 0.0;
        if (uptimeFile.open(QIODevice::ReadOnly | QIODevice::Text))
            uptimeSeconds = QString::fromLatin1(uptimeFile.readAll()).section(QLatin1Char(' '), 0, 0).toDouble();
        result.insert(QStringLiteral("uptime"), formatUptime(uptimeSeconds));

        QFile loadFile(QStringLiteral("/proc/loadavg"));
        if (loadFile.open(QIODevice::ReadOnly | QIODevice::Text))
            result.insert(QStringLiteral("load"), QString::fromLatin1(loadFile.readAll()).section(QLatin1Char(' '), 0, 2));
        else
            result.insert(QStringLiteral("load"), QStringLiteral("Unavailable"));

        const QStorageInfo rootStorage(QStringLiteral("/"));
        if (rootStorage.isValid() && rootStorage.isReady()) {
            const qint64 total = rootStorage.bytesTotal();
            const qint64 available = rootStorage.bytesAvailable();
            const qint64 used = qMax<qint64>(0, total - available);
            result.insert(QStringLiteral("diskTotalGb"), QString::number(double(total) / 1073741824.0, 'f', 1));
            result.insert(QStringLiteral("diskUsedGb"), QString::number(double(used) / 1073741824.0, 'f', 1));
            result.insert(QStringLiteral("diskAvailableGb"), QString::number(double(available) / 1073741824.0, 'f', 1));
            result.insert(QStringLiteral("diskPercent"), total > 0 ? qRound((double(used) / double(total)) * 100.0) : 0);
            result.insert(QStringLiteral("filesystem"), QString::fromLatin1(rootStorage.fileSystemType()));
        } else {
            result.insert(QStringLiteral("diskTotalGb"), QStringLiteral("Unavailable"));
            result.insert(QStringLiteral("diskUsedGb"), QStringLiteral("Unavailable"));
            result.insert(QStringLiteral("diskAvailableGb"), QStringLiteral("Unavailable"));
            result.insert(QStringLiteral("diskPercent"), 0);
            result.insert(QStringLiteral("filesystem"), QStringLiteral("Unavailable"));
        }

        return result;
    }

    Q_INVOKABLE QVariantList networkInterfaces() const
    {
        QVariantList rows;
        QDir netDirectory(QStringLiteral("/sys/class/net"));
        const QStringList interfaces = netDirectory.entryList(QDir::Dirs | QDir::NoDotAndDotDot, QDir::Name);

        for (const QString &name : interfaces) {
            if (name == QStringLiteral("lo"))
                continue;

            const QString basePath = netDirectory.filePath(name);
            auto readText = [](const QString &path) {
                QFile file(path);
                if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
                    return QStringLiteral("Unknown");
                return QString::fromLatin1(file.readAll()).trimmed();
            };

            QVariantMap item;
            item.insert(QStringLiteral("name"), name);
            item.insert(QStringLiteral("state"), readText(basePath + QStringLiteral("/operstate")));
            item.insert(QStringLiteral("address"), readText(basePath + QStringLiteral("/address")));
            item.insert(QStringLiteral("wireless"), QFileInfo::exists(basePath + QStringLiteral("/wireless")));
            rows.append(item);
        }
        return rows;
    }

    Q_INVOKABLE QVariantMap defenderStatus() const
    {
        QVariantMap status;
        const bool scannerAvailable = QFileInfo::exists(QStringLiteral("/usr/bin/clamscan"));
        const bool updaterAvailable = QFileInfo::exists(QStringLiteral("/usr/bin/freshclam"));
        status.insert(QStringLiteral("scannerAvailable"), scannerAvailable);
        status.insert(QStringLiteral("updaterAvailable"), updaterAvailable);
        status.insert(QStringLiteral("engineVersion"), scannerAvailable
            ? runCommand(QStringLiteral("/usr/bin/clamscan"), {QStringLiteral("--version")}, 2500).trimmed()
            : QStringLiteral("Not installed"));

        QDir databaseDirectory(QStringLiteral("/var/lib/clamav"));
        const QStringList databaseFiles = databaseDirectory.entryList(
            {QStringLiteral("*.cvd"), QStringLiteral("*.cld")}, QDir::Files, QDir::Name);
        QDateTime newestDatabase;
        for (const QString &name : databaseFiles) {
            const QFileInfo info(databaseDirectory.filePath(name));
            if (info.lastModified() > newestDatabase)
                newestDatabase = info.lastModified();
        }
        status.insert(QStringLiteral("databasePresent"), !databaseFiles.isEmpty());
        status.insert(QStringLiteral("databaseFiles"), databaseFiles.size());
        status.insert(QStringLiteral("databaseUpdated"), newestDatabase.isValid()
            ? newestDatabase.toLocalTime().toString(QStringLiteral("d MMM yyyy, h:mm AP"))
            : QStringLiteral("Not downloaded yet"));
        const qint64 databaseAgeHours = newestDatabase.isValid()
            ? qMax<qint64>(0, newestDatabase.secsTo(QDateTime::currentDateTime()) / 3600)
            : -1;
        status.insert(QStringLiteral("databaseAgeHours"), databaseAgeHours);
        status.insert(QStringLiteral("databaseHealth"), databaseAgeHours < 0
            ? QStringLiteral("Not downloaded")
            : (databaseAgeHours <= 72 ? QStringLiteral("Recent") : QStringLiteral("Stale — update needed")));
        status.insert(QStringLiteral("updaterService"), updaterAvailable
            ? runCommand(QStringLiteral("/usr/bin/systemctl"),
                {QStringLiteral("is-active"), QStringLiteral("clamav-freshclam.service")}, 2000).trimmed()
            : QStringLiteral("Not installed"));
        status.insert(QStringLiteral("profile"), QStringLiteral("Conservative signatures"));
        status.insert(QStringLiteral("puaEnabled"), false);
        status.insert(QStringLiteral("heuristicsEnabled"), false);
        status.insert(QStringLiteral("defaultScanPath"), defenderDefaultScanPath());
        return status;
    }

    Q_INVOKABLE QString defenderDefaultScanPath() const
    {
        const QString downloads = QDir::home().filePath(QStringLiteral("Downloads"));
        return QDir(downloads).exists() ? downloads : QDir::homePath();
    }

    Q_INVOKABLE void startDefenderScan(const QString &requestedPath)
    {
        if (m_defenderScan && m_defenderScan->state() != QProcess::NotRunning) {
            emit defenderScanFinished(2, QStringLiteral("A Defender scan is already running."), {});
            return;
        }

        QString input = requestedPath.trimmed().isEmpty() ? defenderDefaultScanPath() : requestedPath.trimmed();
        if (input == QStringLiteral("~"))
            input = QDir::homePath();
        else if (input.startsWith(QStringLiteral("~/")))
            input = QDir::home().filePath(input.mid(2));
        else if (!QDir::isAbsolutePath(input))
            input = QDir::home().filePath(input);
        const QFileInfo requestedInfo(input);
        if (!requestedInfo.exists() || requestedInfo.isSymLink()) {
            emit defenderScanFinished(2, QStringLiteral("The selected path does not exist or is a symbolic link."), {});
            return;
        }

        const QString canonicalPath = requestedInfo.canonicalFilePath();
        const QString canonicalHome = QFileInfo(QDir::homePath()).canonicalFilePath();
        if (canonicalPath.isEmpty() || canonicalHome.isEmpty()) {
            emit defenderScanFinished(2, QStringLiteral("Could not resolve the selected path."), {});
            return;
        }
        const QString relative = QDir(canonicalHome).relativeFilePath(canonicalPath);
        if (relative == QStringLiteral("..") || relative.startsWith(QStringLiteral("../"))
            || QDir::isAbsolutePath(relative)) {
            emit defenderScanFinished(2, QStringLiteral("For safety, ADE Defender scans files and folders inside your home directory only."), {});
            return;
        }

        if (!QFileInfo::exists(QStringLiteral("/usr/bin/clamscan"))) {
            emit defenderScanFinished(2, QStringLiteral("ClamAV is not installed in this system image."), {});
            return;
        }

        m_lastDetectionPaths.clear();
        m_lastDetectionHashes.clear();
        m_defenderOutput.clear();
        emit defenderScanProgress(QStringLiteral("Starting conservative ClamAV scan…"));

        auto *process = new QProcess(this);
        m_defenderScan = process;
        process->setProcessChannelMode(QProcess::MergedChannels);
        connect(process, &QProcess::readyReadStandardOutput, this, [this, process]() {
            const QString chunk = QString::fromLocal8Bit(process->readAllStandardOutput());
            if (!chunk.isEmpty()) {
                m_defenderOutput += chunk;
                emit defenderScanProgress(chunk.trimmed());
            }
        });
        connect(process, qOverload<int, QProcess::ExitStatus>(&QProcess::finished), this,
            [this, process](int exitCode, QProcess::ExitStatus exitStatus) {
                const QString remaining = QString::fromLocal8Bit(process->readAllStandardOutput());
                m_defenderOutput += remaining;
                QVariantList detections;
                const QStringList lines = m_defenderOutput.split(QLatin1Char('\n'), Qt::SkipEmptyParts);
                for (const QString &line : lines) {
                    const QString trimmed = line.trimmed();
                    if (!trimmed.endsWith(QStringLiteral(" FOUND")))
                        continue;
                    const int separator = trimmed.lastIndexOf(QStringLiteral(": "));
                    if (separator <= 0)
                        continue;
                    const QString detectedPath = trimmed.left(separator);
                    const QString signature = trimmed.mid(separator + 2, trimmed.size() - separator - 8);
                    if (detectedPath.isEmpty() || signature.isEmpty())
                        continue;
                    QVariantMap row;
                    row.insert(QStringLiteral("path"), detectedPath);
                    row.insert(QStringLiteral("signature"), signature);
                    detections.append(row);
                    m_lastDetectionPaths.append(detectedPath);
                    m_lastDetectionHashes.insert(detectedPath, fileSha256(detectedPath));
                    row.insert(QStringLiteral("sha256"), m_lastDetectionHashes.value(detectedPath));
                }

                QString summary;
                if (exitStatus != QProcess::NormalExit) {
                    summary = QStringLiteral("The scanner stopped unexpectedly. No files were changed.");
                } else if (exitCode == 0) {
                    summary = QStringLiteral("Scan completed. No signature detections were reported.");
                } else if (exitCode == 1) {
                    summary = QStringLiteral("Scan completed with %1 detection(s). Review each result before quarantining.").arg(detections.size());
                } else {
                    summary = QStringLiteral("The scanner reported an error. Check that virus definitions are downloaded and current.");
                }
                if (m_defenderOutput.contains(QStringLiteral("WARNING:"))
                    || m_defenderOutput.contains(QStringLiteral("Can't access file"))
                    || m_defenderOutput.contains(QStringLiteral("Access denied"))) {
                    summary += QStringLiteral(" Some files could not be read; this is not a clean bill of health.");
                }
                emit defenderScanFinished(exitCode, summary, detections);
                m_defenderScan = nullptr;
                process->deleteLater();
            });
        connect(process, &QProcess::errorOccurred, this, [this, process](QProcess::ProcessError error) {
            if (error == QProcess::FailedToStart) {
                emit defenderScanFinished(2, QStringLiteral("ClamAV could not be started. Check the installation."), {});
                m_defenderScan = nullptr;
                process->deleteLater();
            }
        });

        const QStringList arguments = {
            QStringLiteral("--recursive"),
            QStringLiteral("--infected"),
            QStringLiteral("--stdout"),
            QStringLiteral("--heuristic-alerts=no"),
            QStringLiteral("--max-filesize=100M"),
            QStringLiteral("--max-scansize=250M"),
            QStringLiteral("--max-files=5000"),
            QStringLiteral("--max-recursion=12"),
            QStringLiteral("--max-dir-recursion=10"),
            QStringLiteral("--max-scantime=120000"),
            QStringLiteral("--cross-fs=no"),
            canonicalPath
        };
        process->start(QStringLiteral("/usr/bin/clamscan"), arguments);
    }

    Q_INVOKABLE QVariantList defenderQuarantineList() const
    {
        QVariantList rows;
        const QString directoryPath = QDir::home().filePath(QStringLiteral(".local/share/adapteros-defender/quarantine"));
        QDir directory(directoryPath);
        if (!directory.exists())
            return rows;

        const QFileInfoList files = directory.entryInfoList(QDir::Files | QDir::NoDotAndDotDot, QDir::Name);
        for (const QFileInfo &file : files) {
            if (file.fileName().endsWith(QStringLiteral(".json")))
                continue;
            const QString id = file.fileName().section(QLatin1Char('_'), 0, 0);
            QFile metadata(directory.filePath(id + QStringLiteral(".json")));
            QString originalPath;
            QString quarantinedAt;
            if (metadata.open(QIODevice::ReadOnly)) {
                const QJsonObject object = QJsonDocument::fromJson(metadata.readAll()).object();
                originalPath = object.value(QStringLiteral("originalPath")).toString();
                quarantinedAt = object.value(QStringLiteral("quarantinedAt")).toString();
            }
            QVariantMap row;
            row.insert(QStringLiteral("path"), file.canonicalFilePath());
            row.insert(QStringLiteral("name"), file.fileName().section(QLatin1Char('_'), 1));
            row.insert(QStringLiteral("originalPath"), originalPath);
            row.insert(QStringLiteral("quarantinedAt"), quarantinedAt);
            row.insert(QStringLiteral("size"), file.size());
            rows.append(row);
        }
        return rows;
    }

    Q_INVOKABLE QString quarantineDefenderFile(const QString &requestedPath)
    {
        const QString sourcePath = QFileInfo(requestedPath).canonicalFilePath();
        if (sourcePath.isEmpty() || !m_lastDetectionPaths.contains(requestedPath))
            return QStringLiteral("This file is not in the latest scan's detection list.");
        const QFileInfo sourceInfo(sourcePath);
        if (!sourceInfo.isFile() || sourceInfo.isSymLink())
            return QStringLiteral("Only regular files can be quarantined.");
        if (!isWithinHome(sourcePath))
            return QStringLiteral("For safety, only files inside your home directory can be quarantined.");
        const QString expectedHash = m_lastDetectionHashes.value(requestedPath);
        const QString currentHash = fileSha256(sourcePath);
        if (expectedHash.isEmpty() || currentHash.isEmpty() || expectedHash != currentHash)
            return QStringLiteral("The file changed after scanning or could not be verified. Scan it again before quarantining.");

        const QString directoryPath = QDir::home().filePath(QStringLiteral(".local/share/adapteros-defender/quarantine"));
        QDir directory;
        if (!directory.mkpath(directoryPath))
            return QStringLiteral("Could not create the quarantine directory.");
        QFile::setPermissions(directoryPath, QFileDevice::ReadOwner | QFileDevice::WriteOwner | QFileDevice::ExeOwner);

        const QString id = QUuid::createUuid().toString(QUuid::WithoutBraces).remove(QLatin1Char('-'));
        const QString destination = QDir(directoryPath).filePath(id + QLatin1Char('_') + sourceInfo.fileName());
        const QString metadataPath = QDir(directoryPath).filePath(id + QStringLiteral(".json"));
        const QJsonObject metadataObject{
            {QStringLiteral("originalPath"), sourcePath},
            {QStringLiteral("permissions"), static_cast<int>(sourceInfo.permissions())},
            {QStringLiteral("quarantinedAt"), QDateTime::currentDateTimeUtc().toString(Qt::ISODate)},
            {QStringLiteral("sha256"), currentHash}
        };
        QSaveFile metadata(metadataPath);
        if (!metadata.open(QIODevice::WriteOnly)
            || metadata.write(QJsonDocument(metadataObject).toJson(QJsonDocument::Compact)) < 0
            || !metadata.commit()) {
            return QStringLiteral("Could not write quarantine metadata; original file was not changed.");
        }

        bool moved = QFile::rename(sourcePath, destination);
        if (!moved) {
            if (QFile::copy(sourcePath, destination)
                && fileSha256(destination) == metadataObject.value(QStringLiteral("sha256")).toString()
                && QFile::remove(sourcePath)) {
                moved = true;
            } else {
                QFile::remove(destination);
            }
        }
        if (!moved) {
            QFile::remove(metadataPath);
            return QStringLiteral("Could not safely move the file. Original file was left in place.");
        }
        if (fileSha256(destination) != expectedHash) {
            if (QFile::rename(destination, sourcePath)) {
                QFile::remove(metadataPath);
                return QStringLiteral("The file changed during quarantine. It was returned to its original location; scan it again.");
            }
            return QStringLiteral("The quarantined copy did not match the scanned hash. It remains isolated; do not restore it until reviewed.");
        }

        QFile::setPermissions(destination, QFileDevice::ReadOwner | QFileDevice::WriteOwner);
        m_lastDetectionPaths.removeAll(requestedPath);
        return QStringLiteral("Quarantined safely. You can restore it from AdapterOS Defender if it was a false positive.");
    }

    Q_INVOKABLE QString restoreDefenderFile(const QString &requestedQuarantinePath)
    {
        const QString quarantineDirectory = QDir::home().filePath(QStringLiteral(".local/share/adapteros-defender/quarantine"));
        const QString canonicalDirectory = QFileInfo(quarantineDirectory).canonicalFilePath();
        const QFileInfo quarantinedInfo(requestedQuarantinePath);
        const QString canonicalFile = quarantinedInfo.canonicalFilePath();
        if (canonicalDirectory.isEmpty() || canonicalFile.isEmpty() || !quarantinedInfo.isFile()
            || quarantinedInfo.isSymLink() || QFileInfo(canonicalFile).path() != canonicalDirectory) {
            return QStringLiteral("The selected quarantine item is invalid.");
        }

        const QString id = quarantinedInfo.fileName().section(QLatin1Char('_'), 0, 0);
        const QString metadataPath = QDir(canonicalDirectory).filePath(id + QStringLiteral(".json"));
        QFile metadata(metadataPath);
        if (!metadata.open(QIODevice::ReadOnly))
            return QStringLiteral("Quarantine metadata is missing; file was not changed.");
        const QJsonObject object = QJsonDocument::fromJson(metadata.readAll()).object();
        const QString expectedHash = object.value(QStringLiteral("sha256")).toString();
        if (expectedHash.isEmpty() || fileSha256(canonicalFile) != expectedHash)
            return QStringLiteral("The quarantined file has changed or failed its integrity check. It was not restored.");
        const QString originalPath = object.value(QStringLiteral("originalPath")).toString();
        const QString originalParent = QFileInfo(originalPath).dir().canonicalPath();
        if (originalPath.isEmpty() || originalParent.isEmpty() || !isWithinHome(originalParent))
            return QStringLiteral("The original restore location is no longer safe or available.");
        if (QFileInfo::exists(originalPath))
            return QStringLiteral("A file already exists at the original location. Move it first, then retry.");

        bool restored = QFile::rename(canonicalFile, originalPath);
        if (!restored) {
            if (QFile::copy(canonicalFile, originalPath)
                && fileSha256(originalPath) == object.value(QStringLiteral("sha256")).toString()
                && QFile::remove(canonicalFile)) {
                restored = true;
            } else {
                QFile::remove(originalPath);
            }
        }
        if (!restored)
            return QStringLiteral("Could not safely restore the file; it remains quarantined.");

        const auto permissions = static_cast<QFileDevice::Permissions>(object.value(QStringLiteral("permissions")).toInt());
        QFile::setPermissions(originalPath, permissions);
        QFile::remove(metadataPath);
        return QStringLiteral("File restored to its original location. Scan it again if you are unsure it is safe.");
    }

signals:
    void defenderScanProgress(const QString &message);
    void defenderScanFinished(int exitCode, const QString &summary, const QVariantList &detections);

public:
    Q_INVOKABLE QString systemName() const
    {
        const QString name = QSysInfo::prettyProductName();
        return name.isEmpty() ? QStringLiteral("Debian GNU/Linux") : name;
    }

private:
    QProcess *m_defenderScan = nullptr;
    QString m_defenderOutput;
    QStringList m_lastDetectionPaths;
    QHash<QString, QString> m_lastDetectionHashes;

    static QString runCommand(const QString &program, const QStringList &arguments, int timeoutMs)
    {
        QProcess process;
        process.start(program, arguments);
        if (!process.waitForStarted(timeoutMs) || !process.waitForFinished(timeoutMs)) {
            process.kill();
            process.waitForFinished(500);
            return QStringLiteral("Unavailable");
        }
        if (process.exitStatus() != QProcess::NormalExit || process.exitCode() != 0)
            return QStringLiteral("inactive");
        return QString::fromLocal8Bit(process.readAllStandardOutput()).trimmed();
    }

    static bool isWithinHome(const QString &path)
    {
        const QString home = QFileInfo(QDir::homePath()).canonicalFilePath();
        const QString canonical = QFileInfo(path).canonicalFilePath();
        if (home.isEmpty() || canonical.isEmpty())
            return false;
        const QString relative = QDir(home).relativeFilePath(canonical);
        return relative != QStringLiteral("..")
            && !relative.startsWith(QStringLiteral("../"))
            && !QDir::isAbsolutePath(relative);
    }

    static QString fileSha256(const QString &path)
    {
        QFile file(path);
        if (!file.open(QIODevice::ReadOnly))
            return QString();
        QCryptographicHash hash(QCryptographicHash::Sha256);
        while (!file.atEnd()) {
            const QByteArray chunk = file.read(1024 * 1024);
            if (chunk.isEmpty() && file.error() != QFileDevice::NoError)
                return QString();
            hash.addData(chunk);
        }
        return QString::fromLatin1(hash.result().toHex());
    }

    static QString cpuModel()
    {
        QFile cpuInfo(QStringLiteral("/proc/cpuinfo"));
        if (cpuInfo.open(QIODevice::ReadOnly | QIODevice::Text)) {
            while (!cpuInfo.atEnd()) {
                const QString line = QString::fromLocal8Bit(cpuInfo.readLine()).trimmed();
                if (line.startsWith(QStringLiteral("model name")) || line.startsWith(QStringLiteral("Hardware"))
                    || line.startsWith(QStringLiteral("Processor"))) {
                    const int colon = line.indexOf(QLatin1Char(':'));
                    if (colon >= 0)
                        return line.mid(colon + 1).trimmed();
                }
            }
        }
        return QStringLiteral("Not reported by kernel");
    }

    static QString formatUptime(double seconds)
    {
        const qint64 totalSeconds = qMax<qint64>(0, qRound64(seconds));
        const qint64 days = totalSeconds / 86400;
        const qint64 hours = (totalSeconds % 86400) / 3600;
        const qint64 minutes = (totalSeconds % 3600) / 60;
        const qint64 remainder = totalSeconds % 60;
        return days > 0
            ? QStringLiteral("%1d %2h %3m").arg(days).arg(hours).arg(minutes)
            : QStringLiteral("%1h %2m %3s").arg(hours).arg(minutes).arg(remainder);
    }

    static QString helpText()
    {
        return QStringLiteral(
            "ADAPTEROS XP — ADE TERMINAL 0.2.4\n\n"
            "HELP AND INFORMATION\n"
            "  help              Show this command list\n"
            "  about             About AdapterOS XP\n"
            "  version           Show version\n"
            "  sysinfo           Open System Information\n"
            "  whoami            Show the current user\n"
            "  date              Show the date\n"
            "  time              Show the time\n"
            "  echo TEXT         Print text\n\n"
            "APPLICATIONS AND GAMES\n"
            "  games             List built-in games\n"
            "  launch snake      Open Snake\n"
            "  launch calculator Open Calculator\n"
            "  launch notepad    Open Notepad\n"
            "  launch files      Open My Computer\n"
            "  launch taskmgr    Open Task Manager\n"
            "  launch utilities  Open Utilities Center\n"
            "  launch defender   Open AdapterOS Defender\n\n"
            "SYSTEM UTILITIES\n"
            "  tasks             Open Task Manager\n"
            "  disk              Open Disk Usage\n"
            "  network           Open Network Status\n"
            "  clock             Open Clock and Calendar\n"
            "  utilities         Open Utilities Center\n"
            "  defender          Open AdapterOS Defender\n\n"
            "DESKTOP\n"
            "  theme luna|silver|olive|classic\n"
            "  sound test        Play the ADE test sound\n"
            "  clear             Clear the terminal\n"
            "  exit              Close this terminal window\n\n"
            "This is the custom ADE command console. It does not execute arbitrary shell commands.");
    }
};

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QGuiApplication::setApplicationName(QStringLiteral("AdapterOS XP"));
    QGuiApplication::setApplicationVersion(QStringLiteral("0.2.4"));
    QGuiApplication::setOrganizationName(QStringLiteral("AdapterOS"));
    QGuiApplication::setOrganizationDomain(QStringLiteral("adapteros.local"));

    AdeBackend backend;
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("adeBackend"), &backend);

    const QUrl mainUrl(QStringLiteral("qrc:/qml/Main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(EXIT_FAILURE); },
        Qt::QueuedConnection);

    engine.load(mainUrl);
    if (engine.rootObjects().isEmpty())
        return EXIT_FAILURE;

    return app.exec();
}

#include "main.moc"
