extends Node2D

#Variáveis básicas de controle do jogo
var dificuldade = "hard"
var playerVSPlayer=false
var turno = 1

#Função para limpar o tabuleiro
func cleanMatriz():
	return [[" "," "," "],
			[" "," "," "],
			[" "," "," "]]

#Variável tabuleiro
var matriz = cleanMatriz()

#Função que atualiza as imagens vistas no tabuleiro
func changeImages():
	for i in range(matriz.size()):
		for j in range(matriz[i].size()):
			#0
			var path = ""
			path+="AS"
			path+=str(i)
			path+="x"
			path+=str(j)
			if (matriz[i][j]=="o"):
				get_node(path).animation="O"
			#X
			elif (matriz[i][j]=="x"):
				if (dificuldade=="hard"):
					get_node(path).animation="X"
				elif (dificuldade=="medium"):
					get_node(path).animation="X_M"
				elif (dificuldade=="easy"):
					get_node(path).animation="X_E"
			#Vazio
			elif (matriz[i][j]==" "):
				get_node(path).animation="Vazio"
	printarMatriz(matriz)

#Função para mostrar a situação atual do tabuleiro no output
func printarMatriz(matriz):
	for i in range(matriz.size()):
		var line=""
		for j in range(matriz[i].size()):
			if (matriz[i][j]== " "):
				line += " -"
			else: 
				line += " "+matriz[i][j] 
		print(line)
		
#Início
func _ready() -> void:
	start()

#Função de início de partida
func start():
	print("Inicio da partida: ")
	#Animação de vitória é desativada
	get_parent().get_node("SaberAnimation").visible=false
	changeColorButton()
	turno = 1
	$Turno.text= "Turno: "+str(turno)
	matriz = cleanMatriz()
	changeImages()
	$XWinSound.stop()
	$OWinSound.stop()
	
	#Decisão de quem começa a partida	
	var i = intRandom(0,2)
	if (i==0):
		$Estado.text="Vez do Jogador 1"
	else:
		if (playerVSPlayer):
			$Estado.text="Vez do Jogador 2"
		else:
			maquinaStart()

# Função controladora das cores dos botoes
func changeColorButton():
		if (dificuldade== "easy"):
			get_parent().get_node("Button_easy").get("custom_styles/normal").set("bg_color",Color("3b00ff00"))
			get_parent().get_node("Button_medium").get("custom_styles/normal").set("bg_color",Color("3b999999"))
			get_parent().get_node("Button_hard").get("custom_styles/normal").set("bg_color",Color("3b999999"))
		elif (dificuldade== "medium"):
			get_parent().get_node("Button_easy").get("custom_styles/normal").set("bg_color",Color("3b999999"))
			get_parent().get_node("Button_medium").get("custom_styles/normal").set("bg_color",Color("3bffff00"))
			get_parent().get_node("Button_hard").get("custom_styles/normal").set("bg_color",Color("3b999999"))
		elif (dificuldade== "hard"):
			get_parent().get_node("Button_easy").get("custom_styles/normal").set("bg_color",Color("3b999999"))
			get_parent().get_node("Button_medium").get("custom_styles/normal").set("bg_color",Color("3b999999"))
			get_parent().get_node("Button_hard").get("custom_styles/normal").set("bg_color",Color("3bff0000"))
		
#Delay de 1 segundo para a máquina jogar ativando o Timer Maquina
func maquinaStart():
	$Estado.text="Vez da Maquina"
	$Maquina.start()
	
#Jogada da máquina	
func _on_Maquina_timeout() -> void:
	#Toca Som de blaster
	$BlasterSound.play()
	
	#Objeto final {"x":i,"y":j} que determina onde será feita a jogada 
	var p
	
	#Jogada da máquina de acordo com o nível de dificuldade
	#Caso seja o primeiro turno ou a dificuldade seja fácil
	# a maquina joga de forma aleatória
	if (dificuldade=="easy"||turno==1):
		p =random()
		
	#Caso seja dificuldade média tem 70% de chance de usar miniMax
	# e 30% aleatória
	elif (dificuldade=="medium"):
		var n = intRandom(0,10)+1
		if (n>3):
			print("Jogou miniMax no medio")
			p =miniMax()
		else:
			print("Jogou Random no medio")
			p =random()
			
	#No difícil sempre será jogado com miniMax
	elif (dificuldade=="hard"):
		p =miniMax()
	
	#Jogada é realizada no tabuleiro	
	matriz[p.x][p.y]="x"
	
	turno+=1
	$Turno.text= "Turno: "+str(turno)
	print("Maquina joga em: ",p.x,"x",p.y)
	changeImages()
	
	#Caso o jogo termine com a jogada, será executado a animação da vitória e o som
	#correspondente	ao nível de dificuldade. Cada som possui tempos de duração
	#diferente e por isso o wait time de final de jogo é alterado de acordo.
	if (isGameFinish(matriz,false)):
		if ($Estado.text!="Empate"):
			if (dificuldade=="hard"):
				$FimDeJogo.wait_time=3
				$Hard_Win.play()
			elif (dificuldade=="medium"):
				$FimDeJogo.wait_time=1.5
				$Medium_Win.play()
			elif (dificuldade=="easy"):
				$FimDeJogo.wait_time=2
				$Easy_Win.play()
		else:
			$FimDeJogo.wait_time=1.5
		$FimDeJogo.start()
	else:
		#Caso o jogo não terminou o estado é trocado para vez do jogador
		#possibilitando o clique dele no tabuleiro
		$Estado.text="Vez do Jogador 1"

#Sorteia uma posição livre do tabuleiro
func random():
	var x = intRandom(0,3)
	var y = intRandom(0,3)
	while (matriz[x][y]!=" "):
		x = intRandom(0,3)
		y = intRandom(0,3)
	return {"x":x,"y":y}

#Sorteia um número inteiro >= ao minV e < maxV	
func intRandom(minV,maxV):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	return int (rng.randf_range(minV, maxV))
	
#Parte não recursiva do MiniMax
func miniMax():
	#Arrays que gravam todas as jogadas que garantem vitórias, empates e derrotas
	var vitorias = []
	var empates = []
	var derrotas = []
	
	#O tabuleiro é percorrido e todos os espaços vazios são analisados 
	#como possiveis jogadas
	for i in range(matriz.size()):
		for j in range(matriz[i].size()):
			if (matriz[i][j]==" "):
				
				#É feito uma copia do tabuleiro para teste
				var nm = matriz.duplicate(true)
				
				#É feito uma jogada teste na posição vazia correspondente
				#para verificar a situação do tabuleiro após esta jogada
				nm[i][j]="x"
				var result = isGameFinish(nm,true)
				
				#Caso o resultado seja 1, significa que a jogada provocará uma vitoria
				#e é imediatamente retornada como a melhor jogada
				if (String(result) == "1"):
					return {"x":i,"y":j}
				
				#Caso o resultado seja 0, significa que a jogada provocará um empate
				#e é imediatamente retornada, pois é a unica jogada possivel
				elif (String(result) == "0"):
					return {"x":i,"y":j}
					
				#Caso o resultado seja continua, significa que a partida não esta
				#finalizada e será necessário decidir se esta jogada consegue
				#garantir uma vitoria, empate ou derrota atraves do MiniMax recursivo 	
				elif (result == "continua"):
					var v =miniMaxR(nm,false)
					
					#O resultado é armazenado no array correspondente de
					#vitorias,derrotas e empates
					if (v==1):
						vitorias.append({"x":i,"y":j})
					elif (v==0):
						empates.append({"x":i,"y":j})
					elif (v==-1):
						derrotas.append({"x":i,"y":j})
	
	#Se vitorias possui elementos, então sera sorteado um deles para ser retornado
	#Isto gera mais diversidade nas partidas já que mais de uma jogada pode
	#garantir uma vitória.					
	if (vitorias.size()>0):
		var n = intRandom(0,vitorias.size())
		return vitorias[n]
	#Se vitorias não possui elementos, então será sorteado uma garantia de empate.
	elif (empates.size()>0):
		var n = intRandom(0,empates.size())
		return empates[n]
	#Em último caso, caso ocorra uma troca de dificuldade no meio da partida
	#e uma jogada aleatória provoque a impossibilidade de garantia de 
	#vitoria ou empate, uma derrota aleatória será retornada
	else:
		var n = intRandom(0,derrotas.size())
		return derrotas[n]

#Parte Recusiva do MiniMax
#Esta função recebe um estado do tabuleiro e quem esta fazendo a jogada
#No caso de Max ser true seria uma jogada da máquina e no caso se for false,
#seria uma jogada do jogador
func miniMaxR(m,Max):
	
	#A var melhorJogadaValue tem como objetivo apenas encontrar garantias de empates. 
	#Caso a função isGameFinish encontre  um 1 em max ou -1 em min a função miniMaxR
	#retorna imeditamente.
	var melhorJogadaValue
	if (Max):
		melhorJogadaValue=-1
	else:
		melhorJogadaValue=1
		
	# Normalmente isso cobriria todos os casos,	mas existe a situacao onde o jogador
	# altera o nível de dificuldade no meio da partida. Neste caso uma jogada
	# aleatória pode provocar a não garantia de empate. Neste caso a função ira
	# retornar o valor inicial da melhorJOgadaValue -1 em max e 1 em min.
	
	for i in range(m.size()):
		for j in range(m[i].size()):
			if (m[i][j]==" "):
				var nm = m.duplicate(true)
				#Jogada simulada é feita com "x" para a máquina e "o" para o jogador
				if (Max):
					nm[i][j]="x"
				else:
					nm[i][j]="o"
					
				var result = isGameFinish(nm,true)
				
				#Se o resultado for continua, chama miniMaxR enviando a nova
				#situação do tabuleiro e o contrário de Max
				if (String(result)=="continua"):
						result = miniMaxR(nm,!Max)
				if(Max):
					if (result==1):
						return result
					elif (result>melhorJogadaValue):
							melhorJogadaValue= result
				else:
					if (result==-1):
						return result
					elif (result<melhorJogadaValue):
							melhorJogadaValue= result
	return melhorJogadaValue

#Função que recebe um estado de tabuleiro e identifica se o estado é de vitória,
#empate, derrota ou se o jogo continua
#Se for o miniMax que esta utilizando esta função ela retorna e tem um comportamento
#diferente da verifição de final do turno
func isGameFinish(matriz,miniMax):
	
	#Vitórias
	#Linhas
	if (matriz[0][0]==matriz[0][1] and matriz[0][1]==matriz[0][2] and matriz[0][0]!=" "):
		if(miniMax):
			if (matriz[0][0]=="x"):
				return 1
			elif(matriz[0][0]=="o"):
				return -1
		else:	
			print ("Vitoria: ",matriz[0][0])
			if ($Estado.text=="Vez do Jogador 1"):
				$Estado.text="Vitória do Jogador 1"
			elif ($Estado.text=="Vez do Jogador 2"):
				$Estado.text="Vitória do Jogador 2"
			elif ($Estado.text=="Vez da Maquina"):
				$Estado.text="Vitória da Maquina"
			print("Vitoria de linha 1")
			winAnimation(matriz[0][0],"l1")
			return true
	elif (matriz[1][0]==matriz[1][1] and matriz[1][1]==matriz[1][2] and matriz[1][0]!=" "):
		if(miniMax):
			if (matriz[1][0]=="x"):
				return 1
			elif(matriz[1][0]=="o"):
				return -1
		else:
			print ("Vitoria: ",matriz[1][0])
			if ($Estado.text=="Vez do Jogador 1"):
				$Estado.text="Vitória do Jogador 1"
			elif ($Estado.text=="Vez do Jogador 2"):
				$Estado.text="Vitória do Jogador 2"
			elif ($Estado.text=="Vez da Maquina"):
				$Estado.text="Vitória da Maquina"
			print("Vitoria de linha 2")
			winAnimation(matriz[1][0],"l2")
			return true
	elif (matriz[2][0]==matriz[2][1] and matriz[2][1]==matriz[2][2]and matriz[2][0]!=" "):
		if(miniMax):
			if (matriz[2][0]=="x"):
				return 1
			elif(matriz[2][0]=="o"):
				return -1
		else:
			print ("Vitoria: ",matriz[2][0])
			if ($Estado.text=="Vez do Jogador 1"):
				$Estado.text="Vitória do Jogador 1"
			elif ($Estado.text=="Vez do Jogador 2"):
				$Estado.text="Vitória do Jogador 2"
			elif ($Estado.text=="Vez da Maquina"):
				$Estado.text="Vitória da Maquina"
			print("Vitoria de linha 3")
			winAnimation(matriz[2][0],"l3")
			return true
	
	#Colunas
	elif (matriz[0][0]==matriz[1][0] and matriz[1][0]==matriz[2][0] and matriz[0][0]!=" "):
		if(miniMax):
			if (matriz[0][0]=="x"):
				return 1
			elif(matriz[0][0]=="o"):
				return -1
		else:
			print ("Vitoria: ",matriz[0][0])
			if ($Estado.text=="Vez do Jogador 1"):
				$Estado.text="Vitória do Jogador 1"
			elif ($Estado.text=="Vez do Jogador 2"):
				$Estado.text="Vitória do Jogador 2"
			elif ($Estado.text=="Vez da Maquina"):
				$Estado.text="Vitória da Maquina"
			print("Vitoria de coluna 1")
			winAnimation(matriz[0][0],"c1")
			return true
	elif (matriz[0][1]==matriz[1][1] and matriz[1][1]==matriz[2][1] and matriz[0][1]!=" "):
		if(miniMax):
			if (matriz[0][1]=="x"):
				return 1
			elif(matriz[0][1]=="o"):
				return -1
		else:
			print ("Vitoria: ",matriz[0][1])
			if ($Estado.text=="Vez do Jogador 1"):
				$Estado.text="Vitória do Jogador 1"
			elif ($Estado.text=="Vez do Jogador 2"):
				$Estado.text="Vitória do Jogador 2"
			elif ($Estado.text=="Vez da Maquina"):
				$Estado.text="Vitória da Maquina"
			print("Vitoria de coluna 2")
			winAnimation(matriz[0][1],"c2")
			return true
	elif (matriz[0][2]==matriz[1][2] and matriz[1][2]==matriz[2][2] and matriz[0][2]!=" "):
		if(miniMax):
			if (matriz[0][2]=="x"):
				return 1
			elif(matriz[0][2]=="o"):
				return -1
		else:
			print ("Vitoria: ",matriz[0][2])
			if ($Estado.text=="Vez do Jogador 1"):
				$Estado.text="Vitória do Jogador 1"
			elif ($Estado.text=="Vez do Jogador 2"):
				$Estado.text="Vitória do Jogador 2"
			elif ($Estado.text=="Vez da Maquina"):
				$Estado.text="Vitória da Maquina"
			print("Vitoria de coluna 3")
			winAnimation(matriz[0][2],"c3")
			return true		
	
	#Diagonais
	elif (matriz[0][0]==matriz[1][1] and matriz[1][1]==matriz[2][2] and matriz[0][0]!=" "):
		if(miniMax):
			if (matriz[0][0]=="x"):
				return 1
			elif(matriz[0][0]=="o"):
				return -1
		else:
			print ("Vitoria: ",matriz[0][0])
			if ($Estado.text=="Vez do Jogador 1"):
				$Estado.text="Vitória do Jogador 1"
			elif ($Estado.text=="Vez do Jogador 2"):
				$Estado.text="Vitória do Jogador 2"
			elif ($Estado.text=="Vez da Maquina"):
				$Estado.text="Vitória da Maquina"
			print("Vitoria de diagonal 1")
			winAnimation(matriz[0][0],"d1")
			return true
	elif (matriz[2][0]==matriz[1][1] and matriz[1][1]==matriz[0][2] and matriz[2][0]!=" "):
		if(miniMax):
			if (matriz[2][0]=="x"):
				return 1
			elif(matriz[2][0]=="o"):
				return -1	
		else:
			print ("Vitoria: ",matriz[2][0])
			if ($Estado.text=="Vez do Jogador 1"):
				$Estado.text="Vitória do Jogador 1"
			elif ($Estado.text=="Vez do Jogador 2"):
				$Estado.text="Vitória do Jogador 2"
			elif ($Estado.text=="Vez da Maquina"):
				$Estado.text="Vitória da Maquina"
			print("Vitoria de diagonal 2")
			winAnimation(matriz[2][0],"d2")
			return true		
	
	#Empate
	var empate = true
	for i in range(matriz.size()):
		for j in range(matriz[i].size()):
			if (matriz[i][j]==" "):
				empate=false
	if (empate):
		if(miniMax):
			return 0
		else:
			print("empate")
			$Estado.text="Empate"
			return true
	
	#Jogo continua
	if(miniMax):
		return "continua"
	else:
		return false

#Após o timer ser finalizdo o jogo reinicia
func _on_FimDeJogo_timeout() -> void:
	start()
	
#Jogada do Player
func isFree(x,y):
	#Se não for a vez do jogador nada acontece
	if ($Estado.text!="Vez do Jogador 1" and $Estado.text!="Vez do Jogador 2"):
		return
	if (matriz[x][y]==" "):
		$BlasterSound.play()
		turno+=1
		$Turno.text= "Turno: "+str(turno)
		if ($Estado.text=="Vez do Jogador 1"):
			matriz[x][y]="o"
			print("Jogador 1 joga em: ",x,"x",y)
		if ($Estado.text=="Vez do Jogador 2"):
			matriz[x][y]="x"
			print("Jogador 2 joga em: ",x,"x",y)
		changeImages()
		if (isGameFinish(matriz,false)):
			if ($Estado.text!="Empate"):
				if ($Estado.text=="Vitória do Jogador 2"):
					if (dificuldade=="hard"):
						$FimDeJogo.wait_time=3
						$Hard_Win.play()
					elif (dificuldade=="medium"):
						$FimDeJogo.wait_time=1.5
						$Medium_Win.play()
					elif (dificuldade=="easy"):
						$FimDeJogo.wait_time=2
						$Easy_Win.play()
				else:
					$Player_Win.play()
					$FimDeJogo.wait_time=1.5
			else:
				$FimDeJogo.wait_time=1
			$FimDeJogo.start()
		else:
			if ($Estado.text=="Vez do Jogador 2"):
				$Estado.text="Vez do Jogador 1"
			elif($Estado.text=="Vez do Jogador 1" and playerVSPlayer):
				$Estado.text="Vez do Jogador 2"
			else:
			 maquinaStart()
	else:
		print("Jogada nao permitida")

#Ativa a animação do sabre de luz cortando de acordo com o vencedor e na posição
#correta
func winAnimation(vencedor,tipo):
	var typeSaber
	if (vencedor=="x"):
		typeSaber="RedSaber"
	else:
		typeSaber="BlueSaber"
	#Coluna 1	
	if(tipo=="c1"):
		wAPlayer(480,580,0.234,0.872,0,typeSaber)
	#Coluna 2
	elif(tipo=="c2"):
		wAPlayer(710,580,0.234,0.872,0,typeSaber)
	#Coluna 3
	elif(tipo=="c3"):
		wAPlayer(940,580,0.234,0.872,0,typeSaber)
	#Linha 1
	elif(tipo=="l1"):
	 wAPlayer(710,401,0.234,1.152,90,typeSaber)
	#Linha 2
	elif(tipo=="l2"):
	 wAPlayer(710,571,0.234,1.152,90,typeSaber)
	#Linha 3
	elif(tipo=="l3"):
	 wAPlayer(710,741,0.234,1.152,90,typeSaber)
	#Diagonal 1
	elif(tipo=="d1"):
	 wAPlayer(710,580,0.234,1.43,127,typeSaber)
	#Diagonal 2
	elif(tipo=="d2"):
	  wAPlayer(709,586,0.234,1.416,53.1,typeSaber)
	
#Altera tamanho posição, rotação e animação de vitória
func wAPlayer(x,y,scaleX,scaleY,Rotation,typeSaber):
	get_parent().get_node("SaberAnimation").position.x = x
	get_parent().get_node("SaberAnimation").position.y = y
	get_parent().get_node("SaberAnimation").scale.x=scaleX
	get_parent().get_node("SaberAnimation").scale.y=scaleY
	get_parent().get_node("SaberAnimation").rotation_degrees=Rotation
	get_parent().get_node("SaberAnimation").animation=typeSaber
	get_parent().get_node("SaberAnimation").frame=0
	if (typeSaber=="RedSaber"):
		$XWinSound.play()
	else:
		$OWinSound.play()
	get_parent().get_node("SaberAnimation").play()
	get_parent().get_node("SaberAnimation").visible=true
	
#Botões
func _on_Button0x0_pressed() -> void:
	#print("Button 0x0 pressed!")
		isFree(0,0)		

func _on_Button0x1_pressed() -> void:
	#print("Button 0x1 pressed!")
		isFree(0,1)	

func _on_Button0x2_pressed() -> void:
	#print("Button 0x2 pressed!")
		isFree(0,2)	
	
func _on_Button1x0_pressed() -> void:
	#print("Button 1x0 pressed!")
		isFree(1,0)	

func _on_Button1x1_pressed() -> void:
	#print("Button 1x1 pressed!")
		isFree(1,1)	

func _on_Button1x2_pressed() -> void:
	#print("Button 1x2 pressed!")
		isFree(1,2)	

func _on_Button2x0_pressed() -> void:
	#print("Button 2x0 pressed!")
		isFree(2,0)	

func _on_Button2x1_pressed() -> void:
	#print("Button 2x1 pressed!")
		isFree(2,1)	

func _on_Button2x2_pressed() -> void:
	#print("Button 2x2 pressed!")
		isFree(2,2)	

func _on_Button_easy_pressed() -> void:
	dificuldade="easy"
	changeColorButton()
	print(dificuldade)
	changeImages()

func _on_Button_medium_pressed() -> void:
	dificuldade= "medium"
	changeColorButton()
	print(dificuldade)
	changeImages()

func _on_Button_hard_pressed() -> void:
	dificuldade= "hard"
	changeColorButton()
	print(dificuldade)
	changeImages()

func _on_PlayerVsPlayer_pressed() -> void:
	 playerVSPlayer =true
	 get_parent().get_node("PlayerVsMachine").get("custom_styles/normal").set("bg_color",Color("3b6c6c6c"))
	 get_parent().get_node("PlayerVsPlayer").get("custom_styles/normal").set("bg_color",Color("4bffe919"))


func _on_PlayerVsMachine_pressed() -> void:
	 playerVSPlayer =false
	 get_parent().get_node("PlayerVsPlayer").get("custom_styles/normal").set("bg_color",Color("3b6c6c6c"))
	 get_parent().get_node("PlayerVsMachine").get("custom_styles/normal").set("bg_color",Color("4bffe919"))
	

func _on_Restart_pressed() -> void:
	start()


func _on_Sair_pressed() -> void:
	get_tree().quit()
	

#Botao e timer para testes	
func _on_Teste_pressed() -> void:
	print("teste")

func _on_TesteTimer_timeout() -> void:
	return
	
	var tipo = "d2"
	var typeSaber = "RedSaber"
	if(tipo=="c1"):
		wAPlayer(480,580,0.234,0.872,0,typeSaber)
	#Coluna 2
	elif(tipo=="c2"):
		wAPlayer(710,580,0.234,0.872,0,typeSaber)
	#Coluna 3
	elif(tipo=="c3"):
		wAPlayer(940,580,0.234,0.872,0,typeSaber)
	#Linha 1
	elif(tipo=="l1"):
	 wAPlayer(710,401,0.234,1.152,90,typeSaber)
	#Linha 2
	elif(tipo=="l2"):
	 wAPlayer(710,571,0.234,1.152,90,typeSaber)
	#Linha 3
	elif(tipo=="l3"):
	 wAPlayer(710,741,0.234,1.152,90,typeSaber)
	#Diagonal 1
	elif(tipo=="d1"):
	 wAPlayer(710,580,0.234,1.43,127,typeSaber)
	#Diagonal 2
	elif(tipo=="d2"):
	  wAPlayer(709,586,0.234,1.416,53.1,typeSaber)
	
	
	
	
