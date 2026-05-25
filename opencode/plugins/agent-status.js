export const AgentStatusPlugin = async ({ $ }) => {
  const agentStatus =
    process.env.AGENT_STATUS_BIN ??
    (process.env.HOME ? `${process.env.HOME}/.local/bin/agent-status` : "agent-status")

  const setStatus = async (status) => {
    await $`${agentStatus} ${status}`.quiet().nothrow()
  }

  return {
    event: async ({ event }) => {
      switch (event.type) {
        case "session.status":
          if (event.properties?.status?.type === "busy") await setStatus("working")
          if (event.properties?.status?.type === "idle") await setStatus("done")
          break
        case "session.idle":
          await setStatus("done")
          break
        case "permission.asked":
          await setStatus("waiting")
          break
        case "permission.replied":
          await setStatus("working")
          break
      }
    },
  }
}
