using Dominio.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Dominio
{
    public class Pago
    {
        public int IdPago { get; set; }
        public decimal Monto { get; set; }
        public DateTime FechaHora { get; set; }
        public int IdReserva { get; set; }
        public FormaPago FormaDePago { get; set; } 
    }
}
