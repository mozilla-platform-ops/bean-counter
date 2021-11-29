module.exports = {
  apps: [
    {
      name: "glean-beans",
      script: "script/glean-beans.sh",
      instances: 1,
      autorestart: true,
      watch: [
        "script/glean-beans.sh",
      ],
      max_memory_restart: "1G",
      log_file: "glean-beans.log",
      time: true,
    }
  ],
};