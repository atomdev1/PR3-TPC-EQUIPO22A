using Dominio.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Dominio
{
    public class EstadoReserva
    {
        public int IdEstado { get; set; }
        public EstadoReservaEnum  Estado { get; set; }
    }
}
