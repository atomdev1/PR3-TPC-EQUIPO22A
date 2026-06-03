using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Dominio
{
    public class Reserva
    {
        public int IdReserva { get; set; }
        public DateTime Fecha { get; set; }
        public TimeSpan HoraInicio { get; set; }
        public TimeSpan HoraFin { get; set; }
        public decimal PrecioTotal { get; set; }
        public string Observaciones { get; set; }
        public int IdUsuarioCliente { get; set; }
        public int IdUsuarioStaff { get; set; }
        public int IdCancha { get; set; }
        public int IdEstado { get; set; }
        public int IdEstadoPago { get; set; }
        public int IdCupon { get; set; }
    }
}
