import { HttpInterceptorFn, HttpErrorResponse } from '@angular/common/http';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { ToastrService } from 'ngx-toastr';
import { catchError, throwError } from 'rxjs';
import { AuthService } from '../auth/auth';

export const errorHandlerInterceptor: HttpInterceptorFn = (req, next) => {
  const toastr = inject(ToastrService);
  const router = inject(Router);
  const authService = inject(AuthService);

  return next(req).pipe(
    catchError((error: HttpErrorResponse) => {
      let errorMessage = 'An unknown error occurred!';
      if (error.error instanceof ErrorEvent) {
        // Client-side errors
        errorMessage = `Error: ${error.error.message}`;
      } else {
        // Server-side errors
        errorMessage = `Error Code: ${error.status}\nMessage: ${error.message}`;
        if (error.status === 401) {
          toastr.error('Unauthorized. Please log in again.', 'Authentication Error');
          authService.logout();
          router.navigate(['/login']);
        } else if (error.status === 403) {
          toastr.error('You do not have permission to perform this action.', 'Forbidden');
        } else {
          toastr.error(errorMessage, 'API Error');
        }
      }
      return throwError(() => error);
    })
  );
};
