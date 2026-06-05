using System;
using System.Collections.Generic;

namespace Dominio
{
    public class Cancha
    {
        public int IdCancha { get; set; }
        public int Numero { get; set; }
        public string NombreFantasia { get; set; }
        public string Descripcion { get; set; }
        public int CapacidadJugadores { get; set; }
        public decimal Precio { get; set; }
        public decimal MontoSena { get; set; }
        public bool Activa { get; set; }
        public Deporte Deporte { get; set; }
        public List<DisponibilidadCancha> Disponibilidades { get; set; }   // las franjas horarias de la cancha

        public Cancha()
        {
            // arranca vacia asi no explota al recorrerla
            Disponibilidades = new List<DisponibilidadCancha>();
        }
    }
}
