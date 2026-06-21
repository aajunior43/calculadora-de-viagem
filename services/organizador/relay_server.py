import asyncio
import json
import uuid
from datetime import datetime
from typing import Dict, Optional
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

app = FastAPI()
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

agents: Dict[str, WebSocket] = {}
pending_commands: Dict[str, asyncio.Future] = {}
command_results: Dict[str, dict] = {}

@app.websocket("/ws/agent/{agent_id}")
async def agent_ws(websocket: WebSocket, agent_id: str):
    await websocket.accept()
    agents[agent_id] = websocket
    print(f"[{datetime.now()}] Agent connected: {agent_id}")
    try:
        while True:
            data = await websocket.receive_text()
            msg = json.loads(data)
            if msg.get("type") == "command_result":
                cmd_id = msg.get("command_id")
                if cmd_id in pending_commands:
                    pending_commands[cmd_id].set_result(msg)
                    command_results[cmd_id] = msg
    except WebSocketDisconnect:
        agents.pop(agent_id, None)
        print(f"[{datetime.now()}] Agent disconnected: {agent_id}")

@app.websocket("/ws/web")
async def web_ws(websocket: WebSocket):
    await websocket.accept()
    print(f"[{datetime.now()}] Web client connected")
    try:
        while True:
            data = await websocket.receive_text()
            msg = json.loads(data)
            action = msg.get("type")
            if action == "list_agents":
                await websocket.send_text(json.dumps({
                    "type": "agent_list",
                    "agents": list(agents.keys())
                }))
            elif action == "send_command":
                target = msg.get("target_agent")
                if target not in agents:
                    await websocket.send_text(json.dumps({
                        "type": "error",
                        "message": f"Agent {target} not connected"
                    }))
                    continue
                cmd_id = str(uuid.uuid4())
                cmd_msg = {
                    "type": "command",
                    "command_id": cmd_id,
                    "command": msg.get("command"),
                    "params": msg.get("params", {})
                }
                future = asyncio.get_event_loop().create_future()
                pending_commands[cmd_id] = future
                await agents[target].send_text(json.dumps(cmd_msg))
                try:
                    result = await asyncio.wait_for(future, timeout=300)
                    await websocket.send_text(json.dumps({
                        "type": "command_result",
                        "command_id": cmd_id,
                        "agent": target,
                        "result": result
                    }))
                except asyncio.TimeoutError:
                    pending_commands.pop(cmd_id, None)
                    await websocket.send_text(json.dumps({
                        "type": "error",
                        "message": "Command timed out"
                    }))
    except WebSocketDisconnect:
        print(f"[{datetime.now()}] Web client disconnected")

@app.get("/api/agents")
async def list_agents():
    return {"agents": list(agents.keys())}

@app.get("/api/health")
async def health():
    return {"status": "ok", "agents": list(agents.keys())}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8765)
