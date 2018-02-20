-- Global variables on coordinates

mapBoundMinX = 0
mapBoundMaxX = 0
mapBoundMinY = 0
mapBoundMaxY = 0
mapBoundMinZ = 0
mapBoundMaxZ = 0

-- The minimal size of area required to play GMBG
MINBOUNDLENGTH = 1000

WEAPONSPAWNZ = 100

if SERVER then

	-- Start the gamemode when the player calls it via chat.

	function StartGMBG ( player, text, teamChat )

		if ( text ~= "!gmbg start" ) then return end

		if ( not GetMapBounds( player ) ) then

			print( "[GMBG]Fail: Failed to get map bounds." ); return;

		end

		if ( not CheckMapBounds() ) then

			print( "[GMBG]Fail: The play area is too small. Maybe try to initiate at a different position in the map, or change to a bigger map?" ); return;

		end

		SpawnGuns()

		if ( not SpawnPlane() ) then

			print( "[GMBG]Fail: The plane fails to spawn. Try again?" ); return;

		end

	end

	function GetMapBounds( caller )

		-- Use the caller's position as pivot.

		local pivotPos = caller:GetPos()

		if ( not util.IsInWorld( pivotPos ) ) then

			print( "[GMBG]Fail: GMBG's caller is not in the world. Please go to an area where you wish to start GMBG." );

			return false;

		end

		-- Add delta to the pivot and see if it's still in the world.

		local deltaMax = 100000
		local deltaMin = 100

		local delta = deltaMax

		-- Min X

		-- Interpoloate between newPivot and newPivot - delta, and update newPivot.
		local newPivot = pivotPos

		-- Change the delta and try to find the edge of the map bounds.
		while ( true ) do

			-- Base Case: When the delta reaches its minimum, assume that newPivot is close enough to the map bound.
			if ( delta < deltaMin ) then

				mapBoundMinX = newPivot.x; break;

			end

			-- Decrease delta if the guess value is out of the map bound.
			if ( not util.IsInWorld( Vector( newPivot.x - delta, newPivot.y, newPivot.z ) ) ) then

				delta = delta / 2

			-- Move newPivot closer to the map bound.
			else

				newPivot = Vector( newPivot.x - delta, newPivot.y, newPivot.z )

			end

		end

		mapBoundMinX = newPivot.x

		-- Max X
		delta = deltaMax; newPivot = pivotPos;

		while ( true ) do
			if ( delta < deltaMin ) then
				mapBoundMaxX = newPivot.x; break;
			end
			if ( not util.IsInWorld( Vector( newPivot.x + delta, newPivot.y, newPivot.z ) ) ) then
				delta = delta / 2
			else
				newPivot = Vector( newPivot.x + delta, newPivot.y, newPivot.z )
			end
		end
		mapBoundMaxX = newPivot.x

		-- Min Y
		delta = deltaMax; newPivot = pivotPos;

		while ( true ) do
			if ( delta < deltaMin ) then
				mapBoundMinY = newPivot.y; break;
			end
			if ( not util.IsInWorld( Vector( newPivot.x, newPivot.y - delta, newPivot.z ) ) ) then
				delta = delta / 2
			else
				newPivot = Vector( newPivot.x, newPivot.y - delta, newPivot.z )
			end
		end
        mapBoundMinY = newPivot.y

		-- Max Y
		delta = deltaMax; newPivot = pivotPos;

		while ( true ) do
			if ( delta < deltaMin ) then
				mapBoundMaxY = newPivot.y; break;
			end
			if ( not util.IsInWorld( Vector( newPivot.x, newPivot.y + delta, newPivot.z ) ) ) then
				delta = delta / 2
			else
				newPivot = Vector( newPivot.x, newPivot.y + delta, newPivot.z )
			end
		end
		mapBoundMaxY = newPivot.y

		-- Min Z
		while ( true ) do
			if ( delta < deltaMin ) then
				mapBoundMinZ = newPivot.z; break;
			end
			if ( not util.IsInWorld( Vector( newPivot.x, newPivot.y, newPivot.z - delta ) ) ) then
				delta = delta / 2
			else
				newPivot = Vector( newPivot.x, newPivot.y, newPivot.z - delta )
			end
		end
		mapBoundMinZ = newPivot.z

		-- Max Z
		delta = deltaMax; newPivot = pivotPos;

		while ( true ) do
			if ( delta < deltaMin ) then
				mapBoundMaxZ = newPivot.z; break;
			end
			if ( not util.IsInWorld( Vector( newPivot.x, newPivot.y, newPivot.z + delta ) ) ) then
				delta = delta / 2
			else
				newPivot = Vector( newPivot.x, newPivot.y, newPivot.z + delta )
			end

			if ( newPivot.z > 7000 ) then 
				
				newPivot = Vector( newPivot.x, newPivot.y, 7000 ); break;

			end

		end
		mapBoundMaxZ = newPivot.z

		print( "[GMBG]Info: Map bounds are: " .. mapBoundMinX .. ", " .. mapBoundMaxX .. "; " .. mapBoundMinY .. ", " .. mapBoundMaxY .. "; " .. mapBoundMinZ .. ", " .. mapBoundMaxZ )

		return true;

	end

	function CheckMapBounds()

		if ( mapBoundMaxX - mapBoundMinX < MINBOUNDLENGTH ) then return false end
		if ( mapBoundMaxY - mapBoundMinY < MINBOUNDLENGTH ) then return false end
		if ( mapBoundMaxZ - mapBoundMinZ < MINBOUNDLENGTH ) then return false end

		return true

	end

	function SpawnGuns()

		if ( not hasCalledInitPostEntity ) then
			print( "[GMBG]Error: lua/autorun/gmbg.lua: function SpawnGuns: Player tries to start gmbg but GM:InitPostEntity hasn't been called yet." )
			return
		end

		-- Spawn guns randomly.

		local guns = {}

		for i = 1, 20 do

			local x = math.random( mapBoundMinX, mapBoundMaxX)
			local y = math.random( mapBoundMinY, mapBoundMaxY)
			local z = mapBoundMaxZ

			SpawnEntity( "weapon_357", "models/weapons/v_357.mdl", x, y, z )

		end

	end

	function SpawnEntity( entityName, modelName, x, y, z )

		local entity = ents.Create( entityName )
		
		if ( not IsValid( entity ) ) then
			print( "[GMBG]Error: lua/autorun/gmbg.lua: function SpawnEntity: Entity is not valid." )
			return
		end

		entity:SetModel( modelName )
		entity:SetPos( Vector( x, y, z ) )
		entity:Spawn()

		return entity

	end

	function SpawnPlane()

		-- Use an offset to prevent the prop from spawning in a wall.
		local PROPOFFSET = 300

		-- Set the spawn position at a random edge of the map.

		local spawnPos = Vector( 0, 0, 0 )

		local flyDir = Vector( 0, 0, 0 )

		local whichBound = math.random( 0, 3 )

		-- At the left edge
		if whichBound == 0 then

			spawnPos = Vector( mapBoundMinX + PROPOFFSET, math.random( math.floor( mapBoundMinY ) + PROPOFFSET, math.ceil( mapBoundMaxY ) - PROPOFFSET ), mapBoundMaxZ - PROPOFFSET )

			flyDir = Vector( 100, 0, 0 )

		-- At the right edge
		elseif whichBound == 1 then

			spawnPos = Vector( mapBoundMaxX - PROPOFFSET, math.random( math.floor( mapBoundMinY ) + PROPOFFSET, math.ceil( mapBoundMaxY ) - PROPOFFSET ), mapBoundMaxZ - PROPOFFSET )

			flyDir = Vector( -100, 0, 0 )

		-- At the front edge
		elseif whichBound == 2 then

			spawnPos = Vector( math.random( math.floor( mapBoundMinX ) + PROPOFFSET, math.ceil( mapBoundMaxX ) - PROPOFFSET ), mapBoundMaxY - PROPOFFSET, mapBoundMaxZ - PROPOFFSET )

		-- At the back edge
		elseif whichBound == 3 then

			spawnPos = Vector( math.random( math.floor( mapBoundMinX ) + PROPOFFSET, math.ceil( mapBoundMaxX ) - PROPOFFSET ), mapBoundMinY + PROPOFFSET, mapBoundMaxZ - PROPOFFSET )

			flyDir = Vector( 0, 100, 0)

		end

		-- Spawn the visible plane

		plane = ents.Create( "prop_physics" )
		plane:SetModel( "models/hunter/plates/plate8x8.mdl" )
		plane:SetPos( spawnPos )
		plane:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
		plane:Spawn()

		-- Check the plane entity's validity.
		if ( not IsValid( plane ) ) then
			print( "[GMBG]Error: lua/autorun/gmbg.lua: function SpawnPlane: Fail to spawn the plane." )
			return false
		end

		print( "[GMBG]Info: The plane has spawned at: " .. spawnPos.x .. ", " .. spawnPos.y .. ", " .. spawnPos.z )

		-- Set the plane's movement.

		local planePhysObj = plane:GetPhysicsObject()

		planePhysObj:EnableGravity( false )

		planePhysObj:SetVelocity( flyDir )

		-- Spawn the plane's collider.

		planeCollider = ents.Create( "prop_physics" )
		planeCollider:SetModel( "models/hunter/plates/plate8x8.mdl" )
		planeCollider:SetPos( spawnPos )
		planeCollider:Spawn()

		planeCollider:SetMoveType( MOVETYPE_NONE )

		planeCollider:SetColor( Color( 0, 0, 0, 0 ) )
		planeCollider:SetRenderMode( RENDERMODE_TRANSALPHA )

		return true

	end

	-- Calling functions

	print( "[GMBG]Info: lua/autorun/gmbg.lua has started server-side." )

	-- ents.Create has to be called after GM:InitPostEntity is called.

	hasCalledInitPostEntity = false

	hook.Add( "InitPostEntity", "ReportInitPostEntityStatus", function()
		hasCalledInitPostEntity = true
		print( "[GMBG]Info: lua/autorun/gmbg.lua: GM:InitPostEntity has been called." )
	end )

	hook.Add( "PlayerSay", "PlayerStartsGMBG", StartGMBG )

	hook.Add( "Tick", "ServerTicks", function()

		if( IsValid( planeCollider ) && IsValid( plane ) ) then planeCollider:SetPos( plane:GetPos() ) end

	end )

end

