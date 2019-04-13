AVR Linux
=========

Dit zijn instructies om AVR boards werkend te krijgen op Linux, zonder de hulp van Arduino IDE of Atmel Studio.

Hieronder vallen op dit moment:
  * xplainedmini (atmega328p & atmega168p)

## Project script
Het script `xplained_project.sh` maakt een basisvorm van een project map met een standaard ingestelde `F_CPU` en een Makefile. Het programma uitvoeren kan op twee manieren.

	$ sh ./xplained_project.sh

of maak het script uitvoerbaar:

	$ chmod +x xplained_project.sh
	$ xplained_project.sh

Zet het script in een mapje die in de `$PATH` variable staat om het gemakkelijk te kunnen uitvoeren.

### Script info
#### Let op
De kans is groot dat dit script voor het uploaden alleen met de `xplainedmini` boards werkt, aangezien Linux deze printplaat herkent als ttyUSB0, oftewel niet als COM port (zoals wel vaak het geval is bij de arduino printplaatjes).

#### Hulp bij uitvoeren
Voor hulp bij het uitvoeren, run `-h` achter de bestandsnaam.

#### Emacs integration
Als je Emacs gebruikt en syntax checking doet met flycheck, dan is het handig om `-e` bij het maken van het project uit te voeren. `-e` zorgt ervoor dat er een `.dir-locals.el` wordt aangemaakt die met een c-lang flycheck variabele point naar de map waar `avr/io.h` vaak rond hangt. Als flycheck nog steeds aangeeft dat `avr/io.h` niet gevonden is, probeer dan te zoeken naar de map en de variabele te wijzigen voor een werkende flycheck.
Een optie om te zoeken naar de juiste include directory:

	$ locate -A avr io.h

Zodra flycheck niet meer die error geeft, dan is het zaak om een definition toe te voegen om flycheck te vertellen welke board je nou precies gebruikt. De makefile heeft `-mmcu` om aan te geven voor welke board we aan het compilen zijn, daarom is het niet netjes om gewoon een `#define` toe te voegen met de board.

Al check je de `avr/io.h` dan zie je al snel n boel `#ifndef` waar achter atmel microcontroller types staan. Om te fixen dat al die definitions werken van je board, voeg dit voor de `#include <avr/io.h>` in:

	...
	#ifndef __AVR_ATmega328P__
	#define __AVR_ATmega328P__
	#endif
	...
	#include <avr/io.h>
	...
