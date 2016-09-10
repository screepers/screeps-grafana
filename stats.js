// Put in your main loop

if (Memory.stats == undefined) {
  Memory.stats = {}
}

var rooms = Game.rooms
var spawns = Game.spawns
for (let roomKey in rooms) {
  let room = Game.rooms[roomKey]
  var isMyRoom = (room.controller ? room.controller.my : 0)
  if (isMyRoom) {
    Memory.stats['room.' + room.name + '.myRoom'] = 1
    Memory.stats['room.' + room.name + '.energyAvailable'] = room.energyAvailable
    Memory.stats['room.' + room.name + '.energyCapacityAvailable'] = room.energyCapacityAvailable
    Memory.stats['room.' + room.name + '.controllerProgress'] = room.controller.progress
    Memory.stats['room.' + room.name + '.controllerProgressTotal'] = room.controller.progressTotal
    var stored = 0
    var storedTotal = 0

    if (room.storage) {
      stored = room.storage.store[RESOURCE_ENERGY]
      storedTotal = room.storage.storeCapacity[RESOURCE_ENERGY]
    } else {
      stored = 0
      storedTotal = 0
    }

    Memory.stats['room.' + room.name + '.storedEnergy'] = stored
  }else {
    Memory.stats['room.' + room.name + '.myRoom'] = undefined
  }
}
Memory.stats['gcl.progress'] = Game.gcl.progress
Memory.stats['gcl.progressTotal'] = Game.gcl.progressTotal
Memory.stats['gcl.level'] = Game.gcl.level
for (let spawnKey in spawns) {
  let spawn = Game.spawns[spawnKey]
  Memory.stats['spawn.' + spawn.name + '.defenderIndex'] = spawn.memory['defenderIndex']
}

Memory.stats['cpu.CreepManagers'] = creepManagement
Memory.stats['cpu.Towers'] = towersRunning
Memory.stats['cpu.Links'] = linksRunning
Memory.stats['cpu.SetupRoles'] = roleSetup
Memory.stats['cpu.Creeps'] = functionsExecutedFromCreeps
Memory.stats['cpu.SumProfiling'] = sumOfProfiller
Memory.stats['cpu.Start'] = startOfMain
Memory.stats['cpu.bucket'] = Game.cpu.bucket
Memory.stats['cpu.limit'] = Game.cpu.limit
Memory.stats['cpu.stats'] = Game.cpu.getUsed() - lastTick
Memory.stats['cpu.getUsed'] = Game.cpu.getUsed()

