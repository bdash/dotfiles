local M = {}

function M.setup(config)
  config.ssh_domains = {
    {
      name = "merlin",
      remote_address = "merlin.home.bdash.net.nz",
      multiplexing = 'None', -- Let tmux handle multiplexing
    },
    {
      name = "titan",
      remote_address = "titan.home.bdash.net.nz",
      multiplexing = 'None', -- Let tmux handle multiplexing
    },
    {
      name = "atlas",
      remote_address = "atlas.bdash.net.nz",
      multiplexing = 'None', -- Let tmux handle multiplexing
    },
  }
end

return M

