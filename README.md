# 16-bit Assembly (MASM) ile PONG Oyunu

> Efsanevi Pong oyununun, 16-bit DOS ortamı için Assembly (MASM) ile yeniden hayata geçirilmiş hali.

Bu proje, **[Mikroişlemciler]** dersi kapsamında, düşük seviyeli programlama ve donanım yönetimi temellerini anlamak amacıyla geliştirilmiştir. Proje, klasik Pong oyununun temel mekaniklerini (top fiziği, çarpışma algılama, yapay zeka ve puanlama) içermektedir.

<br>

<br>

## 🎯 Temel Özellikler

* **Çift Mod:** Hem iki oyunculu (klavye üzerinden) hem de yapay zekaya karşı (tek oyunculu) oynanabilir.
* **Grafik Modu:** `INT 10h` kesmesi ve `13h` (VGA) modu kullanılarak 320x200, 256 renkli grafik arayüzü.
* **Gerçek Zamanlı Kontrol:** `INT 16h` klavye kesmesi ile anlık tuş okuma ve akıcı raket hareketi.
* **Temel Fizik:** `DRAW_BALL` ve `MOVE_BALL` prosedürleri ile top hareketi, duvardan ve raketten sekme.
* **Puanlama Sistemi:** 5 puana ulaşan oyuncunun kazandığı, `DRAW_GAME_OVER_MENU` ile oyun sonu ekranı.
* **Yapay Zeka:** Basit bir yapay zeka (`CONTROL_BY_AI`), topun Y eksenindeki pozisyonunu takip ederek kendi raketini hareket ettirir.

<br>

## 🛠️ Kullanılan Teknolojiler

* **Dil:** 16-bit Assembly (MASM)
* **Derleyici:** MASM (Microsoft Macro Assembler)
* **Emülatör:** DOSBOX (Modern sistemlerde çalıştırmak için)
* **Editör:** Notepad++

<br>

## 🚀 Kurulum ve Çalıştırma

Bu projeyi çalıştırmak için modern bir işletim sisteminde (Windows/macOS/Linux) **DOSBOX** emülatörüne ihtiyacınız vardır.

### 1. Yöntem: Direkt Oynama (Önerilen)

Eğer sadece oyunu oynamak istiyorsanız, derlenmiş `.EXE` dosyasını kullanabilirsiniz.

1.  Bu reponun **[Releases (Sürümler)]** bölümünden `PONG.EXE` dosyasını indirin.
2.  Bilgisayarınıza **[DOSBOX]'u kurun**.
3.  DOSBOX'u çalıştırın.
4.  Oyunun bulunduğu klasörü DOSBOX'a `mount` edin (bağlayın):
    ```dos
    mount c C:\DosOyunlarim\Pong
    ```
5.  `C:` sürücüsüne geçin:
    ```dos
    C:
    ```
6.  Ondan sonrada sırasoyla şu adımları yapın:
    ```dos
    masm /a pong.asm
    3 kez Enterra bas
    link pong 
    ;
    pong
    ```

### 2. Yöntem: Kaynaktan Derleme (Geliştiriciler İçin)

Eğer kodu kendiniz derlemek isterseniz:

1.  DOSBOX içine `MASM` (ve `LINK.EXE`) dosyalarını kurun.
2.  `Pong.asm` dosyasını indirin.
3.  Kodu derleyin:
    ```dos
    MASM /A PONG.ASM;
    ```
4.  Link (bağlama) yapın:
    ```dos
    LINK PONG.OBJ;
    ```
5.  Oluşturulan `PONG.EXE` dosyasını çalıştırın.

<br>

## 📁 İndirme Linkleri

* **Oyun (.EXE):** **[https://github.com/Arda-ctrl/Assembly-Pong/releases/download/v1.0/PONG.EXE]**
* **Gerekli Emülatör:** **[https://www.dosbox-staging.org/releases/windows/]**

<br>

### 3. Ders İçin Yapılmış Slayt Linki

* **Mikroişlemci Proje Sunumu:** **[https://docs.google.com/presentation/d/1TS__NRF2tZkqJf0Nxnq9BwXnHVhNsbglFZTAsqx6IMI/edit?usp=sharing]

## 📄 Lisans

Bu proje MIT Lisansı altında lisanslanmıştır.
