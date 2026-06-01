using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Dominio
{
    public class Cancha
    {
        public int IdCancha { get; set; }
        public string Nombre { get; set; }
        public bool EstaActiva { get; set; } // Para deshabilitar sin borrar de la BD

        // Composición: Una cancha conoce qué deportes se pueden practicar en ella
        public List<Deporte> DeportesDisponibles { get; set; }

        // Constructor para asegurar que la lista de deportes se inicialice y no tire NullReferenceException
        public Cancha()
        {
            DeportesDisponibles = new List<Deporte>();
        }
    }
}