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
    },
    {
      name: "bake-beans",
      script: "script/bake-beans.sh",
      instances: 1,
      autorestart: true,
      watch: [
        "script/bake-beans.sh",
      ],
      max_memory_restart: "1G",
      log_file: "bake-beans.log",
      time: true,
    },
    {
      name: "stir-beans",
      script: "script/stir-beans.sh",
      instances: 1,
      autorestart: true,
      watch: [
        "script/stir-beans.sh",
      ],
      max_memory_restart: "1G",
      log_file: "stir-beans.log",
      time: true,
    },
  ],
};
