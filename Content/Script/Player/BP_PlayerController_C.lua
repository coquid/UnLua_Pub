---@type BP_PlayerController_C
local M = UnLua.Class()

function M:UserConstructionScript()
	self.ForwardVec = UE.FVector()
	self.RightVec = UE.FVector()
	self.ControlRot = UE.FRotator()

	self.BaseTurnRate = 45.0
	self.BaseLookUpRate = 45.0	
end

function M:ReceiveBeginPlay()
	if self:IsLocalPlayerController() then
		-- 게임 HUD 생성
		self:CreateGameHUD()
		
		-- 게임 완료 위젯 생성 (숨김 상태)
		self:CreateGameCompleteWidget()
	end

	self.Overridden.ReceiveBeginPlay(self)
end

-- 게임 HUD 생성 함수
function M:CreateGameHUD()
	
	local HUDClass = UE.UClass.Load("/Game/ClaudeCode/WBP_GameHUD.WBP_GameHUD_C")
	if HUDClass then
		self.GameHUD = UE.UWidgetBlueprintLibrary.Create(self, HUDClass)
		if self.GameHUD then
			self.GameHUD:AddToViewport()
		end
	end
end

-- 게임 완료 위젯 생성 함수
function M:CreateGameCompleteWidget()
	
	local CompleteClass = UE.UClass.Load("/Game/ClaudeCode/WBP_GameComplete.WBP_GameComplete_C")
	if CompleteClass then
		self.GameComplete = UE.UWidgetBlueprintLibrary.Create(self, CompleteClass)
		if self.GameComplete then
			self.GameComplete:AddToViewport()
			self.GameComplete:SetVisibility(UE.ESlateVisibility.Collapsed)
		end
	end
end

-- 위젯들을 GameManager에 등록
function M:RegisterWidgetsToGameManager()
	local World = self:GetWorld()
	if World and World.GameManagerInstance then
		local GameManager = World.GameManagerInstance
		
		-- HUD 위젯 등록
		if self.GameHUD and GameManager.SetHUDWidget then
			GameManager:SetHUDWidget(self.GameHUD)
		end
		
		-- Victory 위젯 등록
		if self.GameComplete and GameManager.SetVictoryWidget then
			GameManager:SetVictoryWidget(self.GameComplete)
			print("BP_PlayerController_C: Victory 위젯을 GameManager에 수동 등록 완료")
		end
	else
		print("BP_PlayerController_C: GameManager를 찾을 수 없어 위젯 등록 실패")
	end
end

function M:Turn(AxisValue)
	self:AddYawInput(AxisValue)
end

function M:TurnRate(AxisValue)
	local DeltaSeconds = UE.UGameplayStatics.GetWorldDeltaSeconds(self)
	local Value = AxisValue * DeltaSeconds * self.BaseTurnRate
	self:AddYawInput(Value)
end

function M:LookUp(AxisValue)
	self:AddPitchInput(AxisValue)
end

function M:LookUpRate(AxisValue)
	local DeltaSeconds = UE.UGameplayStatics.GetWorldDeltaSeconds(self)
	local Value = AxisValue * DeltaSeconds * self.BaseLookUpRate
	self:AddPitchInput(Value)
end

function M:MoveForward(AxisValue)
	if self.Pawn then
		local Rotation = self:GetControlRotation(self.ControlRot)
		Rotation:Set(0, Rotation.Yaw, 0)
		local Direction = Rotation:ToVector(self.ForwardVec)		-- Rotation:GetForwardVector()
		self.Pawn:AddMovementInput(Direction, AxisValue)
	end
end

function M:MoveRight(AxisValue)
	if self.Pawn then
		local Rotation = self:GetControlRotation(self.ControlRot)
		Rotation:Set(0, Rotation.Yaw, 0)
		local Direction = Rotation:GetRightVector(self.RightVec)
		self.Pawn:AddMovementInput(Direction, AxisValue)
	end
end

function M:Fire_Pressed()
	if self.Pawn then
		self.Pawn:StartFire_Server()
	else
		UE.UKismetSystemLibrary.ExecuteConsoleCommand(self, "RestartLevel")
	end
end

function M:Fire_Released()
	if self.Pawn then
		self.Pawn:StopFire_Server()
	end
end

-- 임시 재시작 키 (R키)
function M:RestartKey_Pressed()
	print("BP_PlayerController_C: R키 눌림 - 게임 재시작 시도")
	UE.UKismetSystemLibrary.ExecuteConsoleCommand(self, "RestartLevel")
end

function M:Aim_Pressed()
	if self.Pawn then
		local BPI_Interfaces = UE.UClass.Load("/Game/Core/Blueprints/BPI_Interfaces.BPI_Interfaces_C")
		BPI_Interfaces.UpdateAiming(self.Pawn, true)
	end
end

function M:Aim_Released()
	if self.Pawn then
		local BPI_Interfaces = UE.UClass.Load("/Game/Core/Blueprints/BPI_Interfaces.BPI_Interfaces_C")
		BPI_Interfaces.UpdateAiming(self.Pawn, false)
	end
end

return M
