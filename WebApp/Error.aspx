<%@ Page Language="C#" %>
<% Response.StatusCode = 500; Response.TrySkipIisCustomErrors = true; %>
<%-- Pagina de error generica. Sin code-behind, no debe poder fallar. --%>
<!DOCTYPE html>
<html>
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Algo salió mal — Complejo Deportivo</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="Site.css" rel="stylesheet" />
</head>
<body class="bg-light d-flex align-items-center justify-content-center min-vh-100">
    <div class="card app-card p-4 text-center" style="width: 440px;">
        <div class="display-1 fw-bold text-success mb-2">500</div>
        <h4 class="fw-semibold mb-2">Algo salió mal</h4>
        <p class="text-muted mb-4">
            Ocurrió un error inesperado. Ya quedó registrado;
            probá de nuevo en un momento.
        </p>
        <a href="Dashboard.aspx" class="btn btn-success w-100">Volver al inicio</a>
    </div>
</body>
</html>
