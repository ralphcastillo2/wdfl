module.exports = {
  apps: [{
    name: 'wdfl',
    cwd: '/root/wdfl',
    script: 'npm',
    args: 'run dev',
    env: {
      NODE_ENV: 'development',
      PORT: 3001,
      HOST: '0.0.0.0'
    },
    env_production: {
      NODE_ENV: 'production',
      PORT: 3001,
      HOST: '0.0.0.0'
    },
    watch: true,
    ignore_watch: ['node_modules', '.next'],
    max_memory_restart: '1G',
    exp_backoff_restart_delay: 100,
    interpreter: '/root/.nvm/versions/node/v22.15.0/bin/node',
    exec_mode: 'fork'
  }]
} 