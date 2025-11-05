STACK SEGMENT PARA STACK
	DB 64 DUP (' ')
STACK ENDS

DATA SEGMENT PARA 'DATA'
	
	WINDOW_WIDTH DW 140h                 ;Pencerenin genişliği (320 piksel)
	WINDOW_HEIGHT DW 0C8h                ;Pencerenin yüksekliği (200 piksel)
	WINDOW_BOUNDS DW 6                   ;Çarpışmaları erken kontrol etmek için kullanılan değişken
	
	TIME_AUX DB 0                        ;Zamanın değişip değişmediğini kontrol ederken kullanılan değişken
	GAME_ACTIVE DB 1                     ;Oyun aktif mi? (1 -> Evet, 0 -> Hayır (oyun bitti))
	EXITING_GAME DB 0
	WINNER_INDEX DB 0                    ;Kazananın endeksi (1 -> birinci oyuncu, 2 -> ikinci oyuncu)
	CURRENT_SCENE DB 0                   ;Mevcut sahnenin dizini (0 -> ana menü, 1 -> oyun)
	
	TEXT_PLAYER_ONE_POINTS DB '0','$'    									;Oyuncu bir puanlı metin
	TEXT_PLAYER_TWO_POINTS DB '0','$'    									;Oyuncu iki noktalı metin
	TEXT_GAME_OVER_TITLE DB 'GAME OVER','$' 								;Oyun bitti menü başlığına sahip metin
	TEXT_GAME_OVER_WINNER DB 'Player 0 won','$' 							;Kazanan metin içeren metin
	TEXT_GAME_OVER_PLAY_AGAIN DB 'Press R to play again','$' 				;Oyun bitti tekrar oyna mesajı içeren metin
	TEXT_GAME_OVER_MAIN_MENU DB 'Press E to exit to main menu','$' 			;Oyun bitti ana menü mesajı içeren metin
	TEXT_MAIN_MENU_TITLE DB 'MAIN MENU','$' 								;Ana menü başlığına sahip metin
	TEXT_MAIN_MENU_SINGLEPLAYER DB 'SINGLEPLAYER - S KEY','$' 				;Tek oyunculu mesaj içeren metin
	TEXT_MAIN_MENU_MULTIPLAYER DB 'MULTIPLAYER - M KEY','$' 				;Çok oyunculu mesaj içeren metin
	TEXT_MAIN_MENU_EXIT DB 'EXIT GAME - E KEY','$' 							;Çıkış oyunu mesajını içeren metin
	
	BALL_ORIGINAL_X DW 0A0h              ;Bir oyunun başlangıcında topun X konumu
	BALL_ORIGINAL_Y DW 64h               ;Bir oyunun başlangıcında topun Y konumu
	BALL_X DW 0A0h                       ;Topun mevcut X konumu (sütun)
	BALL_Y DW 64h                        ;Topun mevcut Y konumu (çizgisi)
	BALL_SIZE DW 06h                     ;Topun boyutu (topun genişliği ve yüksekliği kaç pikseldir)
	BALL_VELOCITY_X DW 05h               ;X (horizontal) velocity of the ball
	BALL_VELOCITY_Y DW 02h               ;Y (vertical) velocity of the ball
	
	PADDLE_LEFT_X DW 0Ah                 ;Sol tahtanın mevcut X konumu
	PADDLE_LEFT_Y DW 55h                 ;Sol tahtanın mevcut Y konumu
	PLAYER_ONE_POINTS DB 0               ;Sol oyuncunun (birinci oyuncu) mevcut puanları
	
	PADDLE_RIGHT_X DW 130h               ;Sağ tahtanın mevcut X konumu
	PADDLE_RIGHT_Y DW 55h                ;Sağ tahtanın mevcut Y konumu
	PLAYER_TWO_POINTS DB 0               ;Sağ oyuncunun (ikinci oyuncu) mevcut puanları
	AI_CONTROLLED DB 0					 ;Sağ tahta yapay zeka tarafından kontrol ediliyor mu
	
	PADDLE_WIDTH DW 06h                  ;Varsayılan tahta genişliği
	PADDLE_HEIGHT DW 25h                 ;Varsayılan tahta yüksekliği
	PADDLE_VELOCITY DW 0Fh               ;Varsayılan tahta hızı

DATA ENDS

CODE SEGMENT PARA 'CODE'

	MAIN PROC FAR
	ASSUME CS:CODE,DS:DATA,SS:STACK      ;Kod, veri ve yığın segmentlerini ilgili kayıtlar olarak varsayalım
	PUSH DS                              ;DS segmentini yığına it
	SUB AX,AX                            ;AX kaydını temizle
	PUSH AX                              ;AX'i yığına it
	MOV AX,DATA                          ;DATA segmentinin içeriğini AX kaydına kaydedin
	MOV DS,AX                            ;DS segmentinde AX'in içeriğini kaydedin
	POP AX                               ;Yığındaki en üst öğeyi AX kayıt defterine bırakın

		
		CALL CLEAR_SCREEN                ;Başlangıç ​​video modu yapılandırmalarını ayarla
		
		CHECK_TIME:                      ;Zaman kontrol döngüsü
			
			CMP EXITING_GAME,01h
			JE START_EXIT_PROCESS
			
			CMP CURRENT_SCENE,00h
			JE SHOW_MAIN_MENU
			
			CMP GAME_ACTIVE,00h
			JE SHOW_GAME_OVER
			
			MOV AH,2Ch 					 ;Sistem saatini al
			INT 21h    					 ;CH = saat CL = dakika DH = saniye DL = 1/100 saniye
			
			CMP DL,TIME_AUX  			 ;Şu anki zaman bir öncekine (TIME_AUX) eşit mi?
			JE CHECK_TIME    		     ;Eğer aynıysa tekrar kontrol edin
			
;           Eğer bu noktaya geldiyse, bunun nedeni zamanın geçmiş olmasıdır
  
			MOV TIME_AUX,DL              ;Güncelleme zamanı
			
			CALL CLEAR_SCREEN            ;Video modunu yeniden başlatarak ekranı temizleyin
			
			CALL MOVE_BALL               ;Top hareketi
			CALL DRAW_BALL               ;Top tasarım çizimi
			
			CALL MOVE_PADDLES            ;İki küreği hareket ettirin (tuşlara basıp basmadığınızı kontrol edin)
			CALL DRAW_PADDLES            ;Güncellenmiş konumlarıyla iki küreği çizin
			
			CALL DRAW_UI                 ;Oyun Kullanıcı Arayüzünü çizin
			
			JMP CHECK_TIME               ;Her şeyi tekrar kontrol ettikten sonra
			
			SHOW_GAME_OVER:
				CALL DRAW_GAME_OVER_MENU
				JMP CHECK_TIME
				
			SHOW_MAIN_MENU:
				CALL DRAW_MAIN_MENU
				JMP CHECK_TIME
				
			START_EXIT_PROCESS:
				CALL CONCLUDE_EXIT_GAME
				
		RET		
	MAIN ENDP
	
	MOVE_BALL PROC NEAR                  ;Topun hareketini işleyin
		
;       Topu yatay olarak hareket ettirin
		MOV AX,BALL_VELOCITY_X    
		ADD BALL_X,AX                   
		
;       Topun sol sınırı geçip geçmediğini kontrol edin (BALL_X < 0 + WINDOW_BOUNDS)
;       Çarpışıyorsa, konumunu yeniden başlatın		
		MOV AX,WINDOW_BOUNDS
		CMP BALL_X,AX                    ;BALL_X, ekranın sol sınırıyla karşılaştırılır (0 + WINDOW_BOUNDS)         
		JL GIVE_POINT_TO_PLAYER_TWO      ;Eğer daha az ise, iki oyuncuya bir puan verin ve topun pozisyonunu sıfırlayın
		
;       Topun doğru sınırı geçip geçmediğini kontrol edin (BALL_X > WINDOW_WIDTH - BALL_SIZE - WINDOW_BOUNDS)
;       Çarpışıyorsa, konumunu yeniden ayarlayın.
		MOV AX,WINDOW_WIDTH
		SUB AX,BALL_SIZE
		SUB AX,WINDOW_BOUNDS
		CMP BALL_X,AX	                ;BALL_X, ekranın sağ sınırıyla karşılaştırılır (BALL_X > WINDOW_WIDTH - BALL_SIZE - WINDOW_BOUNDS)  
		JG GIVE_POINT_TO_PLAYER_ONE     ;Eğer daha büyükse, oyuncuya bir puan verin ve topun pozisyonunu sıfırlayın
		JMP MOVE_BALL_VERTICALLY
		
		GIVE_POINT_TO_PLAYER_ONE:		;Bir oyuncuya bir puan verin ve topun pozisyonunu sıfırlayın
			INC PLAYER_ONE_POINTS       ;Birinci oyuncunun puanını artır
			CALL RESET_BALL_POSITION    ;Topun konumunu ekranın ortasına sıfırla
			
			CALL UPDATE_TEXT_PLAYER_ONE_POINTS ;Oyuncu bir puanlarının metnini güncelle
			
			CMP PLAYER_ONE_POINTS,05h   ;Bu oyuncunun 5 puana ulaşıp ulaşmadığını kontrol edin
			JGE GAME_OVER               ;Eğer bu oyuncunun puanı 5 veya daha fazlaysa oyun biter
			RET
		
		GIVE_POINT_TO_PLAYER_TWO:       ;Oyuncuya bir puan verin ve topun pozisyonunu sıfırlayın
			INC PLAYER_TWO_POINTS       ;Oyuncuya iki puan artış
			CALL RESET_BALL_POSITION    ;Topun konumunu ekranın ortasına sıfırla
			
			CALL UPDATE_TEXT_PLAYER_TWO_POINTS ;Oyuncunun iki noktadaki metnini güncelle
			
			CMP PLAYER_TWO_POINTS,05h   ;Bu oyuncunun 5 puana ulaşıp ulaşmadığını kontrol edin
			JGE GAME_OVER               ;Eğer bu oyuncunun puanı 5 veya daha fazlaysa oyun biter
			RET
			
		GAME_OVER:                      ;Birisi 5 puana ulaştı
			CMP PLAYER_ONE_POINTS,05h   ;Hangi oyuncunun 5 veya daha fazla puanı olduğunu kontrol edin
			JNL WINNER_IS_PLAYER_ONE    ;Eğer birinci oyuncunun en az 5 puanı varsa kazanan olur
			JMP WINNER_IS_PLAYER_TWO    ;Eğer değilse ikinci oyuncu kazanır
			
			WINNER_IS_PLAYER_ONE:
				MOV WINNER_INDEX,01h    ;Kazanan endeksini birinci oyuncunun endeksiyle güncelle
				JMP CONTINUE_GAME_OVER
			WINNER_IS_PLAYER_TWO:
				MOV WINNER_INDEX,02h    ;Kazanan endeksini ikinci oyuncu endeksiyle güncelle
				JMP CONTINUE_GAME_OVER
				
			CONTINUE_GAME_OVER:
				MOV PLAYER_ONE_POINTS,00h   ;Birinci oyuncu puanlarını yeniden başlat
				MOV PLAYER_TWO_POINTS,00h   ;Oyuncuyu iki puanla yeniden başlat
				CALL UPDATE_TEXT_PLAYER_ONE_POINTS
				CALL UPDATE_TEXT_PLAYER_TWO_POINTS
				MOV GAME_ACTIVE,00h         ;Oyunu durdurur
				RET	

;       Topu dikey olarak hareket ettirin		
		MOVE_BALL_VERTICALLY:		
			MOV AX,BALL_VELOCITY_Y
			ADD BALL_Y,AX             
		
;       Topun üst sınırı geçip geçmediğini kontrol edin (BALL_Y < 0 + WINDOW_BOUNDS)
;       Çarpışıyorsa Y'deki hızı tersine çevirin
		MOV AX,WINDOW_BOUNDS
		CMP BALL_Y,AX                    ;BALL_Y, ekranın üst sınırıyla (0 + WINDOW_BOUNDS) karşılaştırılır
		JL NEG_VELOCITY_Y                ;Eğer Y'deki hız daha az ise

;       Topun alt sınırı geçip geçmediğini kontrol edin (BALL_Y > WINDOW_HEIGHT - BALL_SIZE - WINDOW_BOUNDS)
;       Çarpışıyorsa Y'deki hızı tersine çevirin		
		MOV AX,WINDOW_HEIGHT	
		SUB AX,BALL_SIZE
		SUB AX,WINDOW_BOUNDS
		CMP BALL_Y,AX                    ;BALL_Y, ekranın alt sınırıyla karşılaştırılır (BALL_Y > WINDOW_HEIGHT - BALL_SIZE - WINDOW_BOUNDS)
		JG NEG_VELOCITY_Y		         ;Eğer daha büyükse Y'deki hızı tersine çevirin
		
;       Topun doğru raketle çarpışıp çarpışmadığını kontrol edin
; 		maxx1 > minx2 && minx1 < maxx2 && maxy1 > miny2 && miny1 < maxy2
; 		BALL_X + BALL_SIZE > PADDLE_RIGHT_X && BALL_X < PADDLE_RIGHT_X + PADDLE_WIDTH 
; 		&& BALL_Y + BALL_SIZE > PADDLE_RIGHT_Y && BALL_Y < PADDLE_RIGHT_Y + PADDLE_HEIGHT
		
		MOV AX,BALL_X
		ADD AX,BALL_SIZE
		CMP AX,PADDLE_RIGHT_X
		JNG CHECK_COLLISION_WITH_LEFT_PADDLE  ;Çarpışma yoksa sol kürek çarpışmalarını kontrol edin
		
		MOV AX,PADDLE_RIGHT_X
		ADD AX,PADDLE_WIDTH
		CMP BALL_X,AX
		JNL CHECK_COLLISION_WITH_LEFT_PADDLE  ;Çarpışma yoksa sol kürek çarpışmalarını kontrol edin
		
		MOV AX,BALL_Y
		ADD AX,BALL_SIZE
		CMP AX,PADDLE_RIGHT_Y
		JNG CHECK_COLLISION_WITH_LEFT_PADDLE  ;Çarpışma yoksa sol kürek çarpışmalarını kontrol edin
		
		MOV AX,PADDLE_RIGHT_Y
		ADD AX,PADDLE_HEIGHT
		CMP BALL_Y,AX
		JNL CHECK_COLLISION_WITH_LEFT_PADDLE  ;Çarpışma yoksa sol kürek çarpışmalarını kontrol edin
		
;       Eğer bu noktaya ulaşırsa, top sağ kürekle çarpışıyor demektir.

		JMP NEG_VELOCITY_X

;       Topun sol kürekle çarpışıp çarpmadığını kontrol edin
		CHECK_COLLISION_WITH_LEFT_PADDLE:
		; maxx1 > minx2 && minx1 < maxx2 && maxy1 > miny2 && miny1 < maxy2
		; BALL_X + BALL_SIZE > PADDLE_LEFT_X && BALL_X < PADDLE_LEFT_X + PADDLE_WIDTH 
		; && BALL_Y + BALL_SIZE > PADDLE_LEFT_Y && BALL_Y < PADDLE_LEFT_Y + PADDLE_HEIGHT
		
		MOV AX,BALL_X
		ADD AX,BALL_SIZE
		CMP AX,PADDLE_LEFT_X
		JNG EXIT_COLLISION_CHECK  ;Çarpışma çıkış prosedürü yoksa
		
		MOV AX,PADDLE_LEFT_X
		ADD AX,PADDLE_WIDTH
		CMP BALL_X,AX
		JNL EXIT_COLLISION_CHECK  ;Çarpışma çıkış prosedürü yoksa
		
		MOV AX,BALL_Y
		ADD AX,BALL_SIZE
		CMP AX,PADDLE_LEFT_Y
		JNG EXIT_COLLISION_CHECK  ;Çarpışma çıkış prosedürü yoksa
		
		MOV AX,PADDLE_LEFT_Y
		ADD AX,PADDLE_HEIGHT
		CMP BALL_Y,AX
		JNL EXIT_COLLISION_CHECK  ;Çarpışma çıkış prosedürü yoksa
		
;       Eğer bu noktaya ulaşırsa, top sol kürekle çarpışır	

		JMP NEG_VELOCITY_X
		
		NEG_VELOCITY_Y:
			NEG BALL_VELOCITY_Y   ;Topun Y'deki hızını tersine çevirin (BALL_VELOCITY_Y = - BALL_VELOCITY_Y)
			RET
		NEG_VELOCITY_X:
			NEG BALL_VELOCITY_X   ;Topun yatay hızını tersine çevirir
			RET                              
			
		EXIT_COLLISION_CHECK:
			RET
	MOVE_BALL ENDP
	
	MOVE_PADDLES PROC NEAR               ;Tahtaların işlem hareketi
		
;       Sol tahta hareketi
		
										 ;Herhangi bir tuşa basılıp basılmadığını kontrol edin (basılmıyorsa diğer küreği kontrol edin)
		MOV AH,01h
		INT 16h
		JZ CHECK_RIGHT_PADDLE_MOVEMENT   ;ZF = 1, JZ -> Sıfır ise atla
		
										 ;Hangi tuşa basıldığını kontrol et (AL = ASCII karakteri)
		MOV AH,00h
		INT 16h
		
;		Eğer 'w' veya 'W' ise yukarı hareket et
		CMP AL,77h 						 ;'w'
		JE MOVE_LEFT_PADDLE_UP
		CMP AL,57h 						 ;'W'
		JE MOVE_LEFT_PADDLE_UP
		
;		Eğer 's' veya 'S' ise aşağı hareket et
		CMP AL,73h 						 ;'s'
		JE MOVE_LEFT_PADDLE_DOWN
		CMP AL,53h 					     ;'S'
		JE MOVE_LEFT_PADDLE_DOWN
		JMP CHECK_RIGHT_PADDLE_MOVEMENT
		
		MOVE_LEFT_PADDLE_UP:
			MOV AX,PADDLE_VELOCITY
			SUB PADDLE_LEFT_Y,AX
			
			MOV AX,WINDOW_BOUNDS
			CMP PADDLE_LEFT_Y,AX
			JL FIX_PADDLE_LEFT_TOP_POSITION
			JMP CHECK_RIGHT_PADDLE_MOVEMENT
			
			FIX_PADDLE_LEFT_TOP_POSITION:
				MOV PADDLE_LEFT_Y,AX
				JMP CHECK_RIGHT_PADDLE_MOVEMENT
			
		MOVE_LEFT_PADDLE_DOWN:
			MOV AX,PADDLE_VELOCITY
			ADD PADDLE_LEFT_Y,AX
			MOV AX,WINDOW_HEIGHT
			SUB AX,WINDOW_BOUNDS
			SUB AX,PADDLE_HEIGHT
			CMP PADDLE_LEFT_Y,AX
			JG FIX_PADDLE_LEFT_BOTTOM_POSITION
			JMP CHECK_RIGHT_PADDLE_MOVEMENT
			
			FIX_PADDLE_LEFT_BOTTOM_POSITION:
				MOV PADDLE_LEFT_Y,AX
				JMP CHECK_RIGHT_PADDLE_MOVEMENT
		
		
;       Sağ tahta hareketi
		CHECK_RIGHT_PADDLE_MOVEMENT:
		
			CMP AI_CONTROLLED,01 
			JE CONTROL_BY_AI
			
;			Tahta, kullanıcının tuşa basmasıyla kontrol edilir			
			CHECK_FOR_KEYS:
		
;				Eğer 'o' veya 'O' ise yukarı taşı
				CMP AL,6Fh ;'o'
				JE MOVE_RIGHT_PADDLE_UP
				CMP AL,4Fh ;'O'
				JE MOVE_RIGHT_PADDLE_UP
				
;				Eğer 'l' veya 'L' ise aşağı hareket et
				CMP AL,6Ch ;'l'
				JE MOVE_RIGHT_PADDLE_DOWN
				CMP AL,4Ch ;'L'
				JE MOVE_RIGHT_PADDLE_DOWN
				JMP EXIT_PADDLE_MOVEMENT
			
;			Tahta yapay zeka tarafından kontrol ediliyor			
			CONTROL_BY_AI:
				;Topun tahtanın üstünde olup olmadığını kontrol edin(BALL_Y + BALL_SIZE < PADDLE_RIGHT_Y)
				;Eğer yukarı hareket ederse
				MOV AX,BALL_Y 
				ADD AX,BALL_SIZE
				CMP AX,PADDLE_RIGHT_Y
				JL MOVE_RIGHT_PADDLE_UP
				
				
				;Topun tahtanın altında olup olmadığını kontrol edin (BALL_Y > PADDLE_RIGHT_Y + PADDLE_HEIGHT)
				;Eğer aşağı doğru hareket ederse
				MOV AX,PADDLE_RIGHT_Y
				ADD AX,PADDLE_HEIGHT
				CMP AX,BALL_Y 
				JL MOVE_RIGHT_PADDLE_DOWN
				
				;Yukarıdaki koşulların hiçbiri doğru değilse tahtayı hareket ettirmeyin (Tahta hareketinden çıkın)
				JMP EXIT_PADDLE_MOVEMENT

			MOVE_RIGHT_PADDLE_UP:
				MOV AX,PADDLE_VELOCITY
				SUB PADDLE_RIGHT_Y,AX
				
				MOV AX,WINDOW_BOUNDS
				CMP PADDLE_RIGHT_Y,AX
				JL FIX_PADDLE_RIGHT_TOP_POSITION
				JMP EXIT_PADDLE_MOVEMENT
				
				FIX_PADDLE_RIGHT_TOP_POSITION:
					MOV PADDLE_RIGHT_Y,AX
					JMP EXIT_PADDLE_MOVEMENT
			
			MOVE_RIGHT_PADDLE_DOWN:
				MOV AX,PADDLE_VELOCITY
				ADD PADDLE_RIGHT_Y,AX
				MOV AX,WINDOW_HEIGHT
				SUB AX,WINDOW_BOUNDS
				SUB AX,PADDLE_HEIGHT
				CMP PADDLE_RIGHT_Y,AX
				JG FIX_PADDLE_RIGHT_BOTTOM_POSITION
				JMP EXIT_PADDLE_MOVEMENT
				
				FIX_PADDLE_RIGHT_BOTTOM_POSITION:
					MOV PADDLE_RIGHT_Y,AX
					JMP EXIT_PADDLE_MOVEMENT
		
		EXIT_PADDLE_MOVEMENT:
		
			RET
		
	MOVE_PADDLES ENDP
	
	RESET_BALL_POSITION PROC NEAR        ;Top pozisyonunu orijinal pozisyona yeniden başlat
		
		MOV AX,BALL_ORIGINAL_X
		MOV BALL_X,AX
		
		MOV AX,BALL_ORIGINAL_Y
		MOV BALL_Y,AX
		
		NEG BALL_VELOCITY_X
		NEG BALL_VELOCITY_Y
		
		RET
	RESET_BALL_POSITION ENDP
	
	DRAW_BALL PROC NEAR                  
		
		MOV CX,BALL_X                    ;Başlangıç ​​sütununu (X) ayarlayın
		MOV DX,BALL_Y                    ;Başlangıç ​​satırını (Y) ayarlayın
		
		DRAW_BALL_HORIZONTAL:
			MOV AH,0Ch                   ;Yapılandırmayı bir piksel yazmaya ayarlayın
			MOV AL,0Fh 					 ;Renk olarak beyazı seç
			MOV BH,00h 					 ;Sayfa numarasını ayarla
			INT 10h    					 ;Yapılandırmayı yürüt
			
			INC CX     					 ;CX = CX + 1
			MOV AX,CX          	  		 ;CX - BALL_X > BALL_SIZE (Y -> Bir sonraki satıra geçiyoruz,N -> Bir sonraki sütuna devam ediyoruz
			SUB AX,BALL_X
			CMP AX,BALL_SIZE
			JNG DRAW_BALL_HORIZONTAL
			
			MOV CX,BALL_X 				 ;CX kaydı başlangıç ​​sütununa geri döner
			INC DX       				 ;Bir satır ilerliyoruz
			
			MOV AX,DX             		 ;DX - TOP Y > TOP BOYUTU (Y -> bu prosedürden çıkıyoruz, VE -> bir sonraki satıra devam ediyoruz
			SUB AX,BALL_Y
			CMP AX,BALL_SIZE
			JNG DRAW_BALL_HORIZONTAL
		
		RET
	DRAW_BALL ENDP
	
	DRAW_PADDLES PROC NEAR
		
		MOV CX,PADDLE_LEFT_X 			 ;Başlangıç ​​sütununu (X) ayarlayın
		MOV DX,PADDLE_LEFT_Y 			 ;Başlangıç ​​satırını (Y) ayarlayın
		
		DRAW_PADDLE_LEFT_HORIZONTAL:
			MOV AH,0Ch 					 ;Yapılandırmayı bir piksel yazmaya ayarlayın
			MOV AL,0Ah 					 ;Renk olarak beyazı seç
			MOV BH,00h 					 ;Sayfa numarasını ayarla 
			INT 10h    					 ;Yapılandırmayı yürüt
			
			INC CX     				 	 ;CX = CX + 1
			MOV AX,CX         			 ;CX - PADDLE_LEFT_X > PADDLE_WIDTH (Y -> Bir sonraki satıra geçiyoruz,N -> Bir sonraki sütuna devam ediyoruz
			SUB AX,PADDLE_LEFT_X
			CMP AX,PADDLE_WIDTH
			JNG DRAW_PADDLE_LEFT_HORIZONTAL
			
			MOV CX,PADDLE_LEFT_X 		 ;CX kaydı başlangıç ​​sütununa geri döner
			INC DX       				 ;bir satır ilerliyoruz
			
			MOV AX,DX            	     ;DX - PADDLE_LEFT_Y > PADDLE_HEIGHT (Y -> bu prosedürden çıkıyoruz, VE -> bir sonraki satıra devam ediyoruz
			SUB AX,PADDLE_LEFT_Y
			CMP AX,PADDLE_HEIGHT
			JNG DRAW_PADDLE_LEFT_HORIZONTAL
			
			
		MOV CX,PADDLE_RIGHT_X 			 ;Başlangıç ​​sütununu (X) ayarlayın
		MOV DX,PADDLE_RIGHT_Y 			 ;Başlangıç ​​satırını (Y) ayarlayın
		
		DRAW_PADDLE_RIGHT_HORIZONTAL:
			MOV AH,0Ch 					 ;Yapılandırmayı bir piksel yazmaya ayarlayın
			MOV AL,0Ch 					 ;Renk olarak beyazı seç
			MOV BH,00h 					 ;Sayfa numarasını ayarla 
			INT 10h    					 ;Yapılandırmayı yürüt
			
			INC CX     					 ;CX = CX + 1
			MOV AX,CX         			 ;CX - PADDLE_RIGHT_X > PADDLE_WIDTH (Y -> Bir sonraki satıra geçiyoruz,N -> Bir sonraki sütuna devam ediyoruz
			SUB AX,PADDLE_RIGHT_X
			CMP AX,PADDLE_WIDTH
			JNG DRAW_PADDLE_RIGHT_HORIZONTAL
			
			MOV CX,PADDLE_RIGHT_X		 ;CX kaydı başlangıç ​​sütununa geri döner
			INC DX       				 ;Bir satır ilerliyoruz
			
			MOV AX,DX            	     ;DX - PADDLE_RIGHT Y > PADDLE_HEIGHT (Y -> bu prosedürden çıkıyoruz, VE -> bir sonraki satıra devam ediyoruz
			SUB AX,PADDLE_RIGHT_Y
			CMP AX,PADDLE_HEIGHT
			JNG DRAW_PADDLE_RIGHT_HORIZONTAL
			
		RET
	DRAW_PADDLES ENDP
	
	DRAW_UI PROC NEAR
		
;       Soldaki oyuncunun (birinci oyuncu) noktalarını çizin
		
		MOV AH,02h                       ;İmleç konumunu ayarla
		MOV BH,00h                       ;Sayfa numarasını ayarla
		MOV DH,04h                       ;Satır ayarla
		MOV DL,06h						 ;Sütun ayarla
		INT 10h							 
		
		MOV AH,09h                       ;DİZİYİ STANDART ÇIKTIYA YAZ
		LEA DX,TEXT_PLAYER_ONE_POINTS    ;DX'e TEXT_PLAYER_ONE_POINTS dizisine bir işaretçi verin
		INT 21h                          ;Dizeyi yazdır
		
;       Sağdaki oyuncunun (ikinci oyuncu) noktalarını çizin
		
		MOV AH,02h                       ;İmleç konumunu ayarla
		MOV BH,00h                       ;Sayfa numarasını ayarla
		MOV DH,04h                       ;Satır ayarla
		MOV DL,1Fh						 ;Sütun ayarla
		INT 10h							 
		
		MOV AH,09h                       ;DİZİYİ STANDART ÇIKTIYA YAZ
		LEA DX,TEXT_PLAYER_TWO_POINTS    ;DX'e TEXT_PLAYER_ONE_POINTS dizisine bir işaretçi verin
		INT 21h                          ;Dizeyi yazdır
		
		RET
	DRAW_UI ENDP
	
	UPDATE_TEXT_PLAYER_ONE_POINTS PROC NEAR
		
		XOR AX,AX
		MOV AL,PLAYER_ONE_POINTS 		;Örneğin P1 -> 2 nokta => AL,2 verildiğinde
		
										;Şimdi ekrana yazdırmadan önce ondalık değeri ascii kod karakterine dönüştürmemiz gerekiyor 
										;Bunu 30h (sayıyı ASCII'ye) ekleyerek yapabiliriz
										;Ve 30h'yi çıkararak (ASCII sayıya)
		ADD AL,30h                      ;AL,'2'
		MOV [TEXT_PLAYER_ONE_POINTS],AL
		
		RET
	UPDATE_TEXT_PLAYER_ONE_POINTS ENDP
	
	UPDATE_TEXT_PLAYER_TWO_POINTS PROC NEAR
		
		XOR AX,AX
		MOV AL,PLAYER_TWO_POINTS 		;Örneğin P2 -> 2 nokta => AL,2 verildiğinde
		
										;Şimdi ekrana yazdırmadan önce ondalık değeri ASCII kod karakterine dönüştürmemiz gerekiyor 
										;Bunu 30h (sayıyı ASCII'ye) ekleyerek yapabiliriz
										;Ve 30h'yi çıkararak (ASCII sayıya)
		ADD AL,30h                      ;AL,'2'
		MOV [TEXT_PLAYER_TWO_POINTS],AL
		
		RET
	UPDATE_TEXT_PLAYER_TWO_POINTS ENDP
	
	DRAW_GAME_OVER_MENU PROC NEAR        ;Oyun bitti menüsü
		
		CALL CLEAR_SCREEN                ;Menüyü görüntülemeden önce ekranı temizleyin

;       Menü başlığını gösterir
		MOV AH,02h                       ;İmleç konumunu ayarla
		MOV BH,00h                       ;Sayfa numarasını ayarla
		MOV DH,04h                       ;Satır ayarla
		MOV DL,04h						 ;Sütun ayarla
		INT 10h							 
		
		MOV AH,09h                       ;DİZİYİ STANDART ÇIKTIYA YAZ
		LEA DX,TEXT_GAME_OVER_TITLE      ;DX'e bir ipucu ver
		INT 21h                          ;Dizeyi yazdır

;       Kazananı gösterir
		MOV AH,02h                       ;İmleç konumunu ayarla
		MOV BH,00h                       ;Sayfa numarasını ayarla
		MOV DH,06h                       ;Satır ayarla
		MOV DL,04h						 ;Sütun ayarla
		INT 10h							 
		
		CALL UPDATE_WINNER_TEXT
		
		MOV AH,09h                       ;DİZİYİ STANDART ÇIKTIYA YAZ
		LEA DX,TEXT_GAME_OVER_WINNER     ;DX'e bir ipucu ver
		INT 21h                          ;Dizeyi yazdır
		
;       Tekrar oynat mesajını gösterir
		MOV AH,02h                       ;İmleç konumunu ayarla
		MOV BH,00h                       ;Sayfa numarasını ayarla
		MOV DH,08h                       ;Satır ayarla
		MOV DL,04h						 ;Sütun ayarla
		INT 10h							 

		MOV AH,09h                       ;DİZİYİ STANDART ÇIKTIYA YAZ
		LEA DX,TEXT_GAME_OVER_PLAY_AGAIN ;DX'e bir ipucu ver
		INT 21h                          ;Dizeyi yazdır
		
;       Ana menü mesajını gösterir
		MOV AH,02h                       ;İmleç konumunu ayarla
		MOV BH,00h                       ;Sayfa numarasını ayarla
		MOV DH,0Ah                       ;Satır ayarla
		MOV DL,04h						 ;Sütun ayarla
		INT 10h							 

		MOV AH,09h                       ;DİZİYİ STANDART ÇIKTIYA YAZ
		LEA DX,TEXT_GAME_OVER_MAIN_MENU  ;DX'e bir ipucu ver 
		INT 21h                          ;Dizeyi yazdır
		
;       Bir tuşa basılmasını bekler
		MOV AH,00h
		INT 16h

;       Tuş 'R' veya 'r' ise oyunu yeniden başlatın		
		CMP AL,'R'
		JE RESTART_GAME
		CMP AL,'r'
		JE RESTART_GAME
;       Tuş 'E' veya 'e' ise ana menüye çıkın
		CMP AL,'E'
		JE EXIT_TO_MAIN_MENU
		CMP AL,'e'
		JE EXIT_TO_MAIN_MENU
		RET
		
		RESTART_GAME:
			MOV GAME_ACTIVE,01h
			RET
		
		EXIT_TO_MAIN_MENU:
			MOV GAME_ACTIVE,00h
			MOV CURRENT_SCENE,00h
			RET
			
	DRAW_GAME_OVER_MENU ENDP
	
	DRAW_MAIN_MENU PROC NEAR
		
		CALL CLEAR_SCREEN
		
;       Menü başlığını gösterir
		MOV AH,02h                       ;İmleç konumunu ayarla
		MOV BH,00h                       ;Sayfa numarasını ayarla
		MOV DH,04h                       ;Satır ayarla 
		MOV DL,04h						 ;Sütun ayarla
		INT 10h							 
		
		MOV AH,09h                       ;DİZİYİ STANDART ÇIKTIYA YAZ
		LEA DX,TEXT_MAIN_MENU_TITLE      ;DX'e bir ipucu ver
		INT 21h                          ;Dizeyi yazdır
		
;       Tek oyunculu mesajı gösterir
		MOV AH,02h                       ;İmleç konumunu ayarla
		MOV BH,00h                       ;Sayfa numarasını ayarla
		MOV DH,06h                       ;Satır ayarla  
		MOV DL,04h						 ;Sütun ayarla
		INT 10h							 
		
		MOV AH,09h                       ;DİZİYİ STANDART ÇIKTIYA YAZ
		LEA DX,TEXT_MAIN_MENU_SINGLEPLAYER;DX'e bir ipucu ver
		INT 21h                          ;Dizeyi yazdır
		
;       Çok oyunculu mesajı gösterir
		MOV AH,02h                       ;İmleç konumunu ayarla
		MOV BH,00h                       ;Sayfa numarasını ayarla
		MOV DH,08h                       ;Satır ayarla 
		MOV DL,04h						 ;Sütun ayarla
		INT 10h							 
		
		MOV AH,09h                       ;DİZİYİ STANDART ÇIKTIYA YAZ
		LEA DX,TEXT_MAIN_MENU_MULTIPLAYER;DX'e bir ipucu ver
		INT 21h                          ;Dizeyi yazdır
		
;       Çıkış mesajını gösterir
		MOV AH,02h                       ;İmleç konumunu ayarla
		MOV BH,00h                       ;Sayfa numarasını ayarla
		MOV DH,0Ah                       ;Satır ayarla 
		MOV DL,04h						 ;Sütun ayarla
		INT 10h							 
		
		MOV AH,09h                       ;DİZİYİ STANDART ÇIKTIYA YAZ
		LEA DX,TEXT_MAIN_MENU_EXIT       ;DX'e bir ipucu ver
		INT 21h                          ;Dizeyi yazdır
		
		MAIN_MENU_WAIT_FOR_KEY:
;       Bir tuşa basılmasını bekler
			MOV AH,00h
			INT 16h
		
;       Hangi tuşa basıldığını kontrol edin
			CMP AL,'S'
			JE START_SINGLEPLAYER
			CMP AL,'s'
			JE START_SINGLEPLAYER
			CMP AL,'M'
			JE START_MULTIPLAYER
			CMP AL,'m'
			JE START_MULTIPLAYER
			CMP AL,'E'
			JE EXIT_GAME
			CMP AL,'e'
			JE EXIT_GAME
			JMP MAIN_MENU_WAIT_FOR_KEY
			
		START_SINGLEPLAYER:
			MOV CURRENT_SCENE,01h
			MOV GAME_ACTIVE,01h
			MOV AI_CONTROLLED,01h
			
			RET
		
		START_MULTIPLAYER:
			
			MOV CURRENT_SCENE,01h
			MOV GAME_ACTIVE,01h
			MOV AI_CONTROLLED,00h
			RET
		
		EXIT_GAME:
			MOV EXITING_GAME,01h
			RET

	DRAW_MAIN_MENU ENDP
	
	UPDATE_WINNER_TEXT PROC NEAR
		
		MOV AL,WINNER_INDEX              ;Eğer kazanan endeksi 1 ise => AL,1
		ADD AL,30h                       ;AL,31h => AL,'1'
		MOV [TEXT_GAME_OVER_WINNER+7],AL ;Metindeki dizini karakterle güncelle
		
		RET
	UPDATE_WINNER_TEXT ENDP
	
	CLEAR_SCREEN PROC NEAR               ;Video modunu yeniden başlatarak ekranı temizleyin
	
			MOV AH,00h                   ;Yapılandırmayı video moduna ayarlayın
			MOV AL,13h                   ;Video modunu seçin
			INT 10h    					 ;Yapılandırmayı yürüt 
		
			MOV AH,0Bh 					 ;Yapılandırmayı ayarla
			MOV BH,00h 					 ;Arka plan rengine
			MOV BL,00h 					 ;Arka plan rengi olarak siyahı seçin
			INT 10h    					 ;Yapılandırmayı yürüt
			
			RET
			
	CLEAR_SCREEN ENDP
	
	CONCLUDE_EXIT_GAME PROC NEAR         ;Metin moduna geri döner
		
		MOV AH,00h                   	 ;Yapılandırmayı video moduna ayarlayın
		MOV AL,02h                   	 ;Video modunu seçin
		INT 10h    					     ;Yapılandırmayı yürüt
		 
		MOV AH,4Ch                   	 ;Programı sonlandır
		INT 21h

	CONCLUDE_EXIT_GAME ENDP

CODE ENDS
END