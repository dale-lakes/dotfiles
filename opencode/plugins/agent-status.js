export const AgentStatusPlugin = async ({ $ }) => {
  const setStatus = async (status) => {
    await $`agent-status ${status}`.quiet().nothrow()
  }

  return {
    event: async ({ event }) => {
      switch (event.type) {
        case "session.status":
          if (event.properties.status.type === "busy") await setStatus("working")
          if (event.properties.status.type === "idle") await setStatus("done")
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
