using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Dominio
{
    public class Cancha
    {
        public int IdCancha { get; set; } // ID interno único (PK en la BBDD)
        public int NumeroCancha { get; set; } // El número físico (1, 2, 3...)
        public bool EstaActiva { get; set; }
        public int IdDeporte { get; set; } // FK al deporte que se practica en esa cancha
    }
}