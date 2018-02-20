if SERVER then

	function WelcomePlayer( newPlayer )

		newPlayer:PrintMessage( HUD_PRINTTALK, "Hi " .. newPlayer:GetName() .. ", welcome to my server! My name is Botty. Press Y to type. Type !help to get help. Type @botty to chat with me!" )

		--[[-- Create an effect when the player spawns.

		timer.Create( "LateSpawnEffect", 10, 1, function()

			local spawnPos = newPlayer:GetPos()

			local spawnEffectData = EffectData()

			spawnEffectData:SetOrigin( spawnPos )

			print( spawnPos, spawnEffectData )

			util.Effect( "Explosion", spawnEffectData )

		end)--]]

	end

	hook.Add( "PlayerInitialSpawn", "SpawnMessage", WelcomePlayer )

end

