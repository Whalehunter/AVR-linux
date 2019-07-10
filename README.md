# AVR Xplained Mini boards op Linux #

Dit zijn instructies om AVR Xplained Mini boards werkend te krijgen op Linux, zonder de hulp van Arduino IDE of van Atmel Studio.

## Project script ##

Het script `xplained_project.sh` maakt een basic map met een standaard ingestelde .c file en een Makefile. Het programma uitvoeren kan op twee manieren:

	$ sh ./xplained_project.sh

of maak het script uitvoerbaar:

	$ chmod +x xplained_project.sh
	$ xplained_project.sh

Zet het script in een directory die in de `$PATH` variable staat om het gemakkelijk te kunnen uitvoeren.

### Dependencies ###

  * avrdude
  * avr-gcc

### avr-gcc ###

Voor Gentoo gebruikers is de [Arduino](https://wiki.gentoo.org/wiki/Arduino#Prepare_the_toolchain "Arduino - Gentoo Wiki") wiki pagina een goed hulpmiddel om `avr-gcc` aan de praat te krijgen. Voor ondersteuning van de USB apparaten staat de nodige kernel config onder het kopje *Prepare the kernel for USB connection*.

### avrdude ###

Voor Gentoo gebruikers, run simpelweg:

    # emerge -q dev-embedded/avrdude

### Let op ###

De Makefile is niet getest met andere boards dan de AVR Xplained Mini. Het kan zijn dat de Makefile errors geeft bij andere boards.

### Hulp bij uitvoeren ###

Voor hulp bij het uitvoeren, run `-h` achter de bestandsnaam.

### Emacs integration ###

Als je Emacs gebruikt en syntax checking doet met flycheck, dan is het handig om `-e` bij het maken van het project uit te voeren. `-e` zorgt ervoor dat er een `.dir-locals.el` wordt aangemaakt die met een c-lang flycheck variabele point naar de map waar `avr/io.h` vaak rond hangt. Als flycheck nog steeds aangeeft dat `avr/io.h` niet gevonden is, probeer dan te zoeken naar de map en de variabele te wijzigen voor een werkende flycheck.
Een optie om te zoeken naar de juiste include directory:

    $ locate -A avr io.h

Zodra flycheck niet meer die error geeft, dan is het zaak om de board te definen om flycheck te vertellen welke board je nou precies gebruikt, en zo neppe errors te voorkomen.

### Text editor zonder IDE ###

Emacs of niet, als je text editor een checker heeft, en hij geeft aan dat `PORTB1 `of iets in die trant undefined is, zoek dan in `avr/io.h` naar jouw board en sleur/pleur die `#define` naar een regel boven `#include <avr/io.h>` om de errors te laten verdwijnen. Voorbeeld:

    ...
    #ifndef __AVR_ATmega328P__
    #define __AVR_ATmega328P__
    #endif
    ...
    #include <avr/io.h>
    ...

Houd er wel rekening mee dat de `#ifndef` mee wordt genomen, anders gaat de compiler klagen dat ie al defined is.

### Makefile ###

Er wordt een makefile gegenereerd waarbij je de code van je file kan compilen en uploaden naar de AVR microcontroller.\\
Er zijn 3 commands beschikbaar:
  * `make build`
  * `make upload`
  * `make clean`

#### Build ####

1. Maak `bin` directory
2. Compile .c naar .hex

#### Upload ####

Flash .hex naar board d.m.v.

#### Clean ####

Wist alle items uit de `bin` directory

## Seriele communicatie met USART ##

De programma's voor seriele communicatie zitten waarschijnlijk al standaard in je terminal.
Afhankelijk hoe je USART hebt ingesteld, pas je met `stty` instellingen toe om communicatie mogelijk te maken. Voor de volledige instel mogelijkheden raad ik aan om de uitgebreide `man stty` te checken en te zoeken naar hetgeen je wilt aanpassen met `/[zoekterm]`. Hit `h` voor instructies om `man` te gebruiken.\\
Een voorbeeld van een `stty` command:

    $ stty -F /dev/ttyACM0 speed 9600 cs8 parenb -cstopb
Hier is de port **/dev/ttyACM0**, met een baudrate van **9600**, **8** data bits, een **even**-parity bit en **1** stopbit. Als de stdout van `stty` niet gelijk is aan de baudrate of er gezeurd wordt over dat de port busy is, wacht dan ff en probeer het opnieuw.
  * Bij **odd**-parity vervang je `parenb` voor `parodd`
  * Bij **geen** parity laat je beide weg
  * Bij **twee** stopbits gebruik je `cstopb` i.p.v. `-cstopb`

Je zou nu bytes kunnen schrijven d.m.v:

    $ echo '[letter]' > /dev/ttyACM0
Maar met `socat` ontvang je output en kan je input sturen, wat een stuk makkelijker werkt:

    $ socat stdio /dev/ttyACM0

## Tips ##

### Sudo en root gezeur ###

Om irritaties met root en sudo te voorkomen, maak een udev rule om de board vanaf je gebruikersaccount te kunnen benaderen. Aangezien de locatie van de custom udev rules directory per distro anders kan zijn, is hier alleen het voorbeeld van Gentoo:

    # echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="03eb", ATTR{idProduct}=="2145", GROUP="users", MODE="0666"' > /etc/udev/rules.d/50-xplained-mini.rules

Voor het zoeken naar de vendor- en product ID van je microcontroller zou `lsusb` genoeg moeten zijn om je die informatie te verschaffen.
