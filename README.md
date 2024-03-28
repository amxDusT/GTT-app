# App GTT in Flutter per vedere le fermate e la mappa dei mezzi live

Iniziata come un'idea semplice di salvare le mie fermate preferite.. adesso sto cercando di renderla il più completa possibile. 

Alcune features:
- controllo automatico di nuovi aggiornamenti, basati sulle release github.
- cerca per numero fermata o nome e vedi che mezzi passano in fermata (dati da mato.muoversiatorino.it)
- salva le fermate nei preferiti
- aggiungi una descrizione nelle fermate preferite
- mappa delle fermate del bus e posizione live (dati da mapi.5t.torino.it)
- leggi biglietti/carte GTT con NFC 
- lista dei mezzi e i loro 'patterns' (le varie strade possibili del mezzo)
- mappa posizioni live di più mezzi della stessa fermata contemporaneamente

Video example: [LINK](https://drive.google.com/file/d/1FVkPeRsf-s0bkqW8WVDdeUlNkUEHDkaZ/view?usp=drive_link)

<details>
<summary>Screenshots</summary>

| Screenshot 1 | Screenshot 2 | Screenshot 3 | Screenshot 4 | 
|--------------|--------------|--------------|--------------|
| ![Screenshot 1](https://drive.google.com/u/0/uc?id=1bGDpB91XDAopNvX19mBFLJ9ydiQsGc9M) | ![Screenshot 2](https://drive.google.com/u/0/uc?id=1bftxp1xhRIBsZdT-6pV8OQt0n-X_JQIf) | ![Screenshot 3](https://drive.google.com/u/0/uc?id=1AZY5cwjSrJPlR_HKULVPeVbjPjlm5cs_) | ![Screenshot 4](https://drive.google.com/u/0/uc?id=1NXkbKrJewlALQhAQ7_a_EkxEvRFEqkP4) |

</details>

Credits:
- [fabmazz](https://github.com/fabmazz) :
    - come leggere i biglietti GTT
    - come leggere e vedere le posizioni live
    - app libre-busto come feature di riferimento
- [madbob/gtt-pirate-api](https://github.com/madbob/gtt-pirate-api) : API per gli orari dei mezzi
- [MATO](https://mato.muoversiatorino.it/) : orari mezzi e posizione live API
- [5t torino](https://www.5t.torino.it/wp-content/uploads/2022/07/Allegato-A1-Specifica-tecnica-della-smartcard-BIP.pdf) : come leggere carte


# Flutter App GTT for seeing stops and live map of busses

Started as a simple idea to just save my favorite stops.. now I'm trying to make it as much complete as I can.

Some of the features: 
- automatically check for updates based on github releases.
- search by stop num or name and see busses passing in the stop (data from mato.muoversiatorino.it)
- save a stop to favorites
- add description to a stop in favorites
- map of a bus' stops and live busses (data from mapi.5t.torino.it)
- read GTT tickets/cards through NFC
- bus list and patterns
- map of all busses passing in that stop

Video example: [LINK](https://drive.google.com/file/d/1FVkPeRsf-s0bkqW8WVDdeUlNkUEHDkaZ/view?usp=drive_link)

<details>
<summary>Screenshots</summary>

| Screenshot 1 | Screenshot 2 | Screenshot 3 | Screenshot 4 | 
|--------------|--------------|--------------|--------------|
| ![Screenshot 1](https://drive.google.com/u/0/uc?id=1bGDpB91XDAopNvX19mBFLJ9ydiQsGc9M) | ![Screenshot 2](https://drive.google.com/u/0/uc?id=1bftxp1xhRIBsZdT-6pV8OQt0n-X_JQIf) | ![Screenshot 3](https://drive.google.com/u/0/uc?id=1AZY5cwjSrJPlR_HKULVPeVbjPjlm5cs_) | ![Screenshot 4](https://drive.google.com/u/0/uc?id=1NXkbKrJewlALQhAQ7_a_EkxEvRFEqkP4) |

</details>

Credits:
- [fabmazz](https://github.com/fabmazz) :
    - how to read tickets
    - how to read and get live bus positions
    - libre-busto reference for design and what to add
- [madbob/gtt-pirate-api](https://github.com/madbob/gtt-pirate-api) : bus times api
- [MATO](https://mato.muoversiatorino.it/) : bus times and live bus position api
- [5t torino](https://www.5t.torino.it/wp-content/uploads/2022/07/Allegato-A1-Specifica-tecnica-della-smartcard-BIP.pdf) : how to read cards
