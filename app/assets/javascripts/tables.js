$(document).ready(function() {
  $('.datatable').DataTable();

  $('.datatable').closest( '.dataTables_wrapper' ).find( 'select' ).select2( {
    minimumResultsForSearch: -1
  });
})
