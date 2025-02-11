local dap = require('dap')
dap.adapters.lldb = {
  type = 'executable',
  command = 'lldb', -- adjust as needed, must be absolute path
  name = 'lldb'
}

dap.configurations.zig = {
  {
    name = 'Launch',
    type = 'lldb',
    request = 'launch',
    program = 'zig build && DISPLAY=:1 ${workspaceFolder}/zig-out/bin/auto-battler',
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = {},
  },
}

return {}
