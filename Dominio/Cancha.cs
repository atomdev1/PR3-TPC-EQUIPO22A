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
        public int Numero { get; set; } // El número físico de cancha (1, 2, 3...)
        public string NombreFantasia { get; set; }
        public string Descripcion { get; set; }
        public int CapacidadJugadores { get; set; }
        public decimal Precio { get; set; }
        public decimal MontoSena { get; set; }
        public bool Activa { get; set; } // Baja lógica de la cancha
        public int IdDeporte { get; set; } // FK al deporte que se practica en esa cancha
    }
}