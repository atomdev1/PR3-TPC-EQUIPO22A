using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Dominio.Enums;

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
        public int IdDeporte { get; set; }

        public string DeporteNombre
        {
            get { return ((TipoDeporte)IdDeporte).ToString(); }
        }
    }
}