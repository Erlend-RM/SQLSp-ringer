import psycopg2

# MERK: Må kjøres med Python 3

user = '...' # Sett inn ditt UiO-brukernavn ("_priv" blir lagt til under)
pwd = '...' # Sett inn passordet for _priv-brukeren du fikk i en mail

connection = \
    "dbname='" + user + "' " +  \
    "user='" + user + "_priv' " + \
    "port='5432' " +  \
    "host='dbpg-ifi-kurs03.uio.no' " + \
    "password='" + pwd + "'"


def huffsa():
    conn = psycopg2.connect(connection)

    ch = 0
    while (ch != 3):
        print("\n--[ HUFFSA ]--")
        print("Vennligst velg et alternativ:\n 1. Søk etter planet\n 2. Legg inn forsøksresultat\n 3. Avslutt")
        ch = int(input("Valg: "))

        if (ch == 1):
            planet_sok(conn)
        elif (ch == 2):
            legg_inn_resultat(conn)


def planet_sok(conn):
    print("\n--[ PLANET-SØK ]--")
    molekyl1 = input("Molekyl 1: ")
    molekyl2 = input("Molekyl 2: ")

    cur = conn.cursor()

    if molekyl2 == "":
        q = f"SELECT Distinct p.navn, p.masse, s.masse, s.avstand, p.liv \
            FROM planet as p \
                inner join materie as m on(m.planet = p.navn) \
                inner join stjerne as s on(s.navn = p.stjerne) \
                where m.molekyl Like '{molekyl1}' \
                order by s.avstand \
            ;"
    else:
        q = f"with t1 as( \
            SELECT Distinct p.navn, p.masse as pmasse, s.masse as smasse, s.avstand, p.liv \
            FROM planet as p \
                inner join materie as m on(m.planet = p.navn) \
                inner join stjerne as s on(s.navn = p.stjerne) \
            where m.molekyl Like '{molekyl1}' \
            order by s.avstand \
            ), \
             \
            t2 as ( \
            SELECT Distinct p.navn, p.masse as pmasse, s.masse as smasse, s.avstand, p.liv \
            FROM planet as p \
                inner join materie as m on(m.planet = p.navn) \
                inner join stjerne as s on(s.navn = p.stjerne) \
            where m.molekyl Like '{molekyl2}' \
            order by s.avstand) \
            SELECT Distinct t1.navn, t1.pmasse, t1.smasse, t1.avstand, t1.liv \
            FROM t1 \
                inner join t2 on(t1.navn = t2.navn \
            ); \
            "

    cur.execute(q)
    rader = cur.fetchall()
    for rad in rader:
        print("\n--Planet--")
        print(f"Navn: {rad[0]}")
        print(f"Planet-masse: {rad[1]}")
        print(f"Stjerne-masse: {rad[2]}")
        print(f"Stjerne-distanse: {rad[3]}")
        if rad[4] == True:
            print("Bekreftet liv: Ja")
        else:
            print("Bekreftet liv: Nei")

    cur.close()


def legg_inn_resultat(conn):
    print("\n--[ LEGG INN RESULTAT ]--")
    planet = input("Planet: ")
    skummel = input("Skummel: ")
    if skummel == "j":
        skummel = True
    elif skummel == "n":
        skummel = False
    intelligent = input("Interlligent: ")
    if intelligent == "j":
        intelligent = True
    elif intelligent == "n":
        intelligent = False
    beskrivelse = input("Beskrivelse: ")

    cur = conn.cursor()

    q = f"UPDATE planet\
        SET skummel = {skummel}, intelligent = {intelligent}, beskrivelse = '{beskrivelse}' \
        where navn = '{planet}' \
        ;"
    cur.execute(q)

    cur2 = conn.cursor()
    q2 = f"SELECT * \
    FROM planet \
    where navn = '{planet}'\
    ;"
    cur2.execute(q2)
    cur2.comit()
    print(f"\n{planet} er oppdatert")
    print(cur2.fetchall())


    cur.close()
    cur2.close()


if __name__ == "__main__":
    huffsa()
